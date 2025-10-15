using UnityEngine;
using PupilLabs;
using System.Collections.Generic;

public class CustomEyeTrackingCalibration : MonoBehaviour
{
    [Header("Canvas Setup")]
    public Transform canvasTransform; // Your image display canvas
    public Camera vrCamera; // Main VR camera

    [Header("Calibration Controls")]
    public KeyCode recordPointKey = KeyCode.Space;
    public KeyCode nextCornerKey = KeyCode.N;
    public KeyCode startCalibrationKey = KeyCode.C;
    public KeyCode testModeKey = KeyCode.T;

    [Header("Visual Indicators")]
    public GameObject calibrationIndicator; // Visual point to show current corner
    public float indicatorSize = 0.05f;

    [Header("Calibration Settings")]
    public int samplesPerCorner = 10; // How many samples to average per corner

    // Private variables
    private NeonGazeDataProvider gazeDataProvider;
    private bool isCalibrating = false;
    private bool isInTestMode = false;
    private int currentCornerIndex = 0;
    private int currentSampleCount = 0;

    // Corner positions in world space
    private Vector3[] cornerWorldPositions = new Vector3[4];
    private string[] cornerNames = { "Top Left", "Top Right", "Bottom Right", "Bottom Left" };

    // Calibration data
    private List<Vector2>[] rawGazeSamples = new List<Vector2>[4];
    private Vector2[] averageRawGazePerCorner = new Vector2[4];
    private Vector2[] canvasCornerPositions = new Vector2[4];

    // Calibration transformation matrix
    private bool isCalibrated = false;
    private Matrix4x4 calibrationMatrix = Matrix4x4.identity;

    // Current gaze data
    private Vector2 currentRawGaze = Vector2.zero;
    private Vector2 currentCalibratedGaze = Vector2.zero;

    void Start()
    {
        // Initialize
        gazeDataProvider = FindObjectOfType<NeonGazeDataProvider>();
        if (vrCamera == null) vrCamera = Camera.main;

        if (gazeDataProvider != null)
        {
            Debug.Log("✓ Found NeonGazeDataProvider - ready for custom calibration");
            gazeDataProvider.gazeDataReady.AddListener(OnGazeDataReceived);
        }
        else
        {
            Debug.LogError("✗ NeonGazeDataProvider not found!");
        }

        // Initialize sample collections
        for (int i = 0; i < 4; i++)
        {
            rawGazeSamples[i] = new List<Vector2>();
        }

        SetupCanvasCorners();

        if (calibrationIndicator != null)
            calibrationIndicator.SetActive(false);
    }

    void Update()
    {
        if (Input.GetKeyDown(startCalibrationKey))
        {
            StartCalibration();
        }

        if (Input.GetKeyDown(testModeKey))
        {
            ToggleTestMode();
        }

        if (isCalibrating)
        {
            if (Input.GetKeyDown(recordPointKey))
            {
                RecordCalibrationPoint();
            }

            if (Input.GetKeyDown(nextCornerKey))
            {
                NextCorner();
            }
        }

        // Update calibrated gaze position if we have calibration
        if (isCalibrated)
        {
            currentCalibratedGaze = ApplyCalibration(currentRawGaze);
        }
    }

    void SetupCanvasCorners()
    {
        if (canvasTransform == null)
        {
            Debug.LogError("Canvas Transform not assigned!");
            return;
        }

        // Get canvas bounds
        Renderer canvasRenderer = canvasTransform.GetComponent<Renderer>();
        if (canvasRenderer == null)
        {
            Debug.LogError("Canvas must have a Renderer component!");
            return;
        }

        Bounds bounds = canvasRenderer.bounds;

        // Define corner positions in world space
        cornerWorldPositions[0] = new Vector3(bounds.min.x, bounds.max.y, bounds.center.z); // Top Left
        cornerWorldPositions[1] = new Vector3(bounds.max.x, bounds.max.y, bounds.center.z); // Top Right
        cornerWorldPositions[2] = new Vector3(bounds.max.x, bounds.min.y, bounds.center.z); // Bottom Right
        cornerWorldPositions[3] = new Vector3(bounds.min.x, bounds.min.y, bounds.center.z); // Bottom Left

        // Convert to canvas local coordinates (0,0 to 1,1)
        canvasCornerPositions[0] = new Vector2(0, 1); // Top Left
        canvasCornerPositions[1] = new Vector2(1, 1); // Top Right
        canvasCornerPositions[2] = new Vector2(1, 0); // Bottom Right
        canvasCornerPositions[3] = new Vector2(0, 0); // Bottom Left

        Debug.Log("Canvas corners set up successfully");
    }

    void StartCalibration()
    {
        if (gazeDataProvider == null) return;

        isCalibrating = true;
        currentCornerIndex = 0;
        currentSampleCount = 0;

        // Clear previous calibration data
        for (int i = 0; i < 4; i++)
        {
            rawGazeSamples[i].Clear();
        }

        ShowCalibrationPoint();

        Debug.Log("=== CUSTOM CALIBRATION STARTED ===");
        Debug.Log($"Look at the {cornerNames[currentCornerIndex]} corner and press SPACE to record");
    }

    void ShowCalibrationPoint()
    {
        if (calibrationIndicator != null)
        {
            calibrationIndicator.transform.position = cornerWorldPositions[currentCornerIndex];
            calibrationIndicator.transform.localScale = Vector3.one * indicatorSize;
            calibrationIndicator.SetActive(true);
        }
    }

    void RecordCalibrationPoint()
    {
        if (!isCalibrating || gazeDataProvider == null) return;

        // Record current raw gaze position
        rawGazeSamples[currentCornerIndex].Add(currentRawGaze);
        currentSampleCount++;

        Debug.Log($"Recorded sample {currentSampleCount}/{samplesPerCorner} for {cornerNames[currentCornerIndex]} - Raw gaze: {currentRawGaze}");

        if (currentSampleCount >= samplesPerCorner)
        {
            // Calculate average for this corner
            Vector2 sum = Vector2.zero;
            foreach (Vector2 sample in rawGazeSamples[currentCornerIndex])
            {
                sum += sample;
            }
            averageRawGazePerCorner[currentCornerIndex] = sum / rawGazeSamples[currentCornerIndex].Count;

            Debug.Log($"✓ {cornerNames[currentCornerIndex]} completed. Average raw gaze: {averageRawGazePerCorner[currentCornerIndex]}");

            // Move to next corner or finish
            if (currentCornerIndex < 3)
            {
                NextCorner();
            }
            else
            {
                FinishCalibration();
            }
        }
    }

    void NextCorner()
    {
        if (currentSampleCount < samplesPerCorner)
        {
            Debug.Log($"Need {samplesPerCorner - currentSampleCount} more samples for {cornerNames[currentCornerIndex]}");
            return;
        }

        currentCornerIndex++;
        currentSampleCount = 0;

        if (currentCornerIndex < 4)
        {
            ShowCalibrationPoint();
            Debug.Log($"Now look at {cornerNames[currentCornerIndex]} and press SPACE to record");
        }
    }

    void FinishCalibration()
    {
        isCalibrating = false;
        if (calibrationIndicator != null)
            calibrationIndicator.SetActive(false);

        // Calculate calibration transformation
        CalculateCalibrationTransformation();

        Debug.Log("=== CALIBRATION COMPLETED ===");
        Debug.Log("Press T to test calibrated gaze tracking");
    }

    void CalculateCalibrationTransformation()
    {
        // Simple bilinear interpolation setup
        // This maps the 4 raw gaze corner points to the 4 canvas corner points

        Vector2 rawTopLeft = averageRawGazePerCorner[0];
        Vector2 rawTopRight = averageRawGazePerCorner[1];
        Vector2 rawBottomRight = averageRawGazePerCorner[2];
        Vector2 rawBottomLeft = averageRawGazePerCorner[3];

        // Store calibration bounds for mapping
        rawGazeMin = new Vector2(
            Mathf.Min(rawTopLeft.x, rawBottomLeft.x),
            Mathf.Min(rawBottomLeft.y, rawBottomRight.y)
        );
        rawGazeMax = new Vector2(
            Mathf.Max(rawTopRight.x, rawBottomRight.x),
            Mathf.Max(rawTopLeft.y, rawTopRight.y)
        );

        isCalibrated = true;

        Debug.Log($"Calibration bounds - Raw min: {rawGazeMin}, Raw max: {rawGazeMax}");
    }

    private Vector2 rawGazeMin, rawGazeMax;

    Vector2 ApplyCalibration(Vector2 rawGaze)
    {
        if (!isCalibrated) return rawGaze;

        // Normalize raw gaze to 0-1 based on calibration bounds
        Vector2 normalizedGaze = new Vector2(
            Mathf.InverseLerp(rawGazeMin.x, rawGazeMax.x, rawGaze.x),
            Mathf.InverseLerp(rawGazeMin.y, rawGazeMax.y, rawGaze.y)
        );

        // Clamp to valid range
        normalizedGaze = new Vector2(
            Mathf.Clamp01(normalizedGaze.x),
            Mathf.Clamp01(normalizedGaze.y)
        );

        return normalizedGaze;
    }

    void ToggleTestMode()
    {
        isInTestMode = !isInTestMode;
        Debug.Log($"Test mode: {(isInTestMode ? "ON" : "OFF")}");
    }

    void OnGazeDataReceived(GazeDataProvider gazeProvider)
    {
        currentRawGaze = gazeProvider.RawGazePoint;

        if (isInTestMode && isCalibrated)
        {
            Debug.Log($"Raw: {currentRawGaze:F2} -> Calibrated: {currentCalibratedGaze:F3}");
        }
    }

    void OnGUI()
    {
        GUILayout.BeginArea(new Rect(10, 10, 500, 400));

        GUILayout.Label("=== CUSTOM EYE TRACKING CALIBRATION ===");
        GUILayout.Label($"Gaze Provider: {(gazeDataProvider != null ? "Connected" : "Not Connected")}");
        GUILayout.Label($"Calibrating: {isCalibrating}");
        GUILayout.Label($"Calibrated: {isCalibrated}");
        GUILayout.Label($"Test Mode: {isInTestMode}");

        if (isCalibrating)
        {
            GUILayout.Space(10);
            GUILayout.Label($"Current Corner: {cornerNames[currentCornerIndex]} ({currentCornerIndex + 1}/4)");
            GUILayout.Label($"Samples: {currentSampleCount}/{samplesPerCorner}");
            GUILayout.Label($"Instructions:");
            GUILayout.Label($"1. Look at the {cornerNames[currentCornerIndex]} corner");
            GUILayout.Label($"2. Press SPACE to record gaze point");
            GUILayout.Label($"3. Repeat {samplesPerCorner} times");
        }

        GUILayout.Space(10);
        GUILayout.Label($"Raw Gaze: {currentRawGaze:F2}");
        if (isCalibrated)
        {
            GUILayout.Label($"Calibrated Gaze: {currentCalibratedGaze:F3}");
        }

        GUILayout.Space(10);
        GUILayout.Label("Controls:");
        GUILayout.Label($"C - Start Calibration");
        GUILayout.Label($"SPACE - Record Point (during calibration)");
        GUILayout.Label($"N - Next Corner (during calibration)");
        GUILayout.Label($"T - Toggle Test Mode");

        if (isCalibrated)
        {
            GUILayout.Space(10);
            if (GUILayout.Button("Start New Calibration"))
            {
                StartCalibration();
            }
        }

        GUILayout.EndArea();
    }

    public Vector2 GetCalibratedGazePosition()
    {
        return currentCalibratedGaze;
    }

    public bool IsCalibrated()
    {
        return isCalibrated;
    }

    void OnDestroy()
    {
        if (gazeDataProvider != null)
        {
            gazeDataProvider.gazeDataReady.RemoveListener(OnGazeDataReceived);
        }
    }
}