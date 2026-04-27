const videoElement = document.getElementsByClassName('video-input')[0];
const canvasElement = document.getElementsByClassName('output-canvas')[0];
const canvasCtx = canvasElement.getContext('2d');
const loadingOverlay = document.getElementById('loadingOverlay');
const toggleMeshBtn = document.getElementById('toggleMesh');

let isMeshVisible = true;

toggleMeshBtn.addEventListener('click', () => {
    isMeshVisible = !isMeshVisible;
    if (isMeshVisible) {
        toggleMeshBtn.classList.add('active');
    } else {
        toggleMeshBtn.classList.remove('active');
    }
});

const ringSprites = {
    top: new Image(),
    angle45: new Image(),
    side: new Image()
};
// Using a simpler gold ring PNG
const ringUrl = "https://pngimg.com/uploads/ring/ring_PNG30.png";
ringSprites.top.src = ringUrl;
ringSprites.angle45.src = ringUrl;
ringSprites.side.src = ringUrl;

// --- HELPER: Get Finger Orientation ---
const getFingerOrientation = (mcp, pip, wrist) => {
    // 3D vector from MCP to PIP
    const dx = pip.x - mcp.x;
    const dy = pip.y - mcp.y;
    const dz = pip.z - mcp.z; // Depth difference

    // Calculate Pitch (Tilt up/down)
    // If dz is large negative, finger points INTO screen (Top View)
    // If dz is near 0, finger is flat (Side/Top hybrid depends on rotation)

    // We also need "Roll" or "Yaw" of the hand to see if it's palm-facing or side-facing.
    // Thumb vs Pinky Z-depth is a good proxy for hand rotation.
    // But basic Z-depth of finger segment is a good start.

    // Normalized Z component (approx sine of angle with screen plane)
    const len = Math.sqrt(dx * dx + dy * dy + dz * dz);
    const zDir = dz / len;

    // Heuristics for Sprite Selection:
    // zDir < -0.5  => Finger pointing CA at camera (Top View)
    // zDir > -0.5 && zDir < 0.2 => Slight Angle (45 deg)
    // zDir > 0.2 => Flat / Side View (Side Sprite)

    if (zDir < -0.6) return 'top';
    if (zDir < -0.2) return 'angle45';
    return 'side';

    // Note: This is a simplified heuristic. 
    // Ideally we use the Hand Normal (Wrist -> Index x Wrist -> Pinky) for better precision.
};

// --- 2D RING DRAWING ---
const drawRing2D = (landmarks) => {
    // 1. Get Ring Finger Landmarks (3D)
    // 13: MCP (Knuckle), 14: PIP (Middle Joint)
    // 0: Wrist (Reference)
    const mcp = landmarks[13];
    const pip = landmarks[14];
    const wrist = landmarks[0];

    // 2. Calculate Position & Size
    const cx = (mcp.x * 0.8 + pip.x * 0.2) * canvasElement.width;
    const cy = (mcp.y * 0.8 + pip.y * 0.2) * canvasElement.height;

    const dx = (pip.x - mcp.x) * canvasElement.width;
    const dy = (pip.y - mcp.y) * canvasElement.height;
    const fingerLen = Math.sqrt(dx * dx + dy * dy);

    const size = fingerLen * 1.1;

    // 3. Calculate Rotation
    const angle = Math.atan2(dy, dx);

    // 4. Select Sprite based on Orientation
    const view = getFingerOrientation(mcp, pip, wrist);
    let sprite = ringSprites.top; // Default
    if (view === 'angle45') sprite = ringSprites.angle45;
    if (view === 'side') sprite = ringSprites.side;

    // 5. Draw Image with Transform
    canvasCtx.save();
    canvasCtx.translate(cx, cy);
    canvasCtx.rotate(angle - Math.PI / 2); // Align ring top with finger tip

    // "Cut it half" logic: Clip the bottom part of the ring to simulate it going *under* the finger
    // Assuming the image is a top-down view circle, the bottom arc is the "back" band.
    // We clip to keep only the top ~70% of the image visible.

    // Create clipping mask
    canvasCtx.beginPath();
    canvasCtx.rect(-size / 2, -size / 2, size, size * 0.70);
    canvasCtx.clip();

    // Ensure image is loaded
    if (sprite.complete && sprite.naturalHeight !== 0) {
        // Shadow
        canvasCtx.shadowColor = "rgba(0,0,0,0.5)";
        canvasCtx.shadowBlur = 10;
        canvasCtx.shadowOffsetX = 2;
        canvasCtx.shadowOffsetY = 2;

        canvasCtx.drawImage(sprite, -size / 2, -size / 2, size, size);

        canvasCtx.shadowColor = "transparent";
    } else {
        // Fallback
        canvasCtx.beginPath();
        canvasCtx.arc(0, 0, size / 3, 0, 2 * Math.PI);
        canvasCtx.strokeStyle = "gold";
        canvasCtx.lineWidth = 5;
        canvasCtx.stroke();
    }

    canvasCtx.restore();
};

// --- NECK MESH DRAWING ---
const drawNeckMesh = (faceLandmarks, poseLandmarks) => {
    const poseColor = '#D4AF3740'; // Semi-transparent Gold
    const meshColor = '#FFFFFF40'; // Transparent white to match face mesh

    // 1. Get Key Anchors
    // We'll pick a subset for the "top" of the neck mesh
    const jawIndices = [58, 172, 136, 150, 176, 152, 400, 379, 365, 397, 288];
    const jawPoints = jawIndices.map(idx => faceLandmarks[idx]);

    // Pose: Shoulders
    const leftShoulder = poseLandmarks[11];
    const rightShoulder = poseLandmarks[12];

    // 2. Generate "Collarbone" Row (Bottom of Neck Mesh)
    const collarPoints = [];
    const steps = jawPoints.length;
    for (let i = 0; i < steps; i++) {
        const t = i / (steps - 1);
        let x = rightShoulder.x + (leftShoulder.x - rightShoulder.x) * t;
        let y = rightShoulder.y + (leftShoulder.y - rightShoulder.y) * t;

        // Add deeper curve for "Necklace" look on the chest
        y += 0.15 * 4 * t * (1 - t);

        // Widen slightly more to cover trapezius area better
        const scale = 0.85;
        const centerX = (leftShoulder.x + rightShoulder.x) / 2;
        x = centerX + (x - centerX) * scale;

        collarPoints.push({ x, y });
    }

    // 3. Generate Intermediate Rows and Triangulate
    const rows = [jawPoints];
    const numInterRows = 7; // High density for smooth look

    for (let r = 1; r <= numInterRows; r++) {
        const tRow = r / (numInterRows + 1);
        const row = [];

        // Curve factor: Narrower in middle.
        const pinchStrength = 0.25;
        const pinchFactor = 1.0 - (4 * tRow * (1 - tRow) * pinchStrength);

        for (let i = 0; i < steps; i++) {
            const start = jawPoints[i];
            const end = collarPoints[i];

            // 1. Interpolation
            let x = start.x + (end.x - start.x) * tRow;
            let y = start.y + (end.y - start.y) * tRow;

            // 2. Apply Pinch
            const rowCenterX = (rows[0][0].x + rows[0][steps - 1].x) / 2;
            x = rowCenterX + (x - rowCenterX) * pinchFactor;

            row.push({ x, y });
        }
        rows.push(row);
    }
    rows.push(collarPoints);

    // 4. Draw Triangulated Mesh
    canvasCtx.fillStyle = meshColor;
    canvasCtx.strokeStyle = meshColor;
    canvasCtx.lineWidth = 0.5;

    // Connect points
    for (let r = 0; r < rows.length - 1; r++) {
        const currentRow = rows[r];
        const nextRow = rows[r + 1];

        for (let i = 0; i < steps - 1; i++) {
            const p1 = currentRow[i];
            const p2 = currentRow[i + 1];
            const p3 = nextRow[i];
            const p4 = nextRow[i + 1];

            // Draw Triangle 1 (p1, p2, p3)
            canvasCtx.beginPath();
            canvasCtx.moveTo(p1.x * canvasElement.width, p1.y * canvasElement.height);
            canvasCtx.lineTo(p2.x * canvasElement.width, p2.y * canvasElement.height);
            canvasCtx.lineTo(p3.x * canvasElement.width, p3.y * canvasElement.height);
            canvasCtx.stroke();

            // Draw Triangle 2 (p2, p4, p3)
            canvasCtx.beginPath();
            canvasCtx.moveTo(p2.x * canvasElement.width, p2.y * canvasElement.height);
            canvasCtx.lineTo(p4.x * canvasElement.width, p4.y * canvasElement.height);
            canvasCtx.lineTo(p3.x * canvasElement.width, p3.y * canvasElement.height);
            canvasCtx.stroke();
        }
    }

    // Draw Outline for Neck
    canvasCtx.strokeStyle = poseColor;
    canvasCtx.lineWidth = 1;
    canvasCtx.beginPath();
    // Left side
    canvasCtx.moveTo(jawPoints[0].x * canvasElement.width, jawPoints[0].y * canvasElement.height);
    for (let r = 1; r < rows.length; r++) {
        const p = rows[r][0];
        canvasCtx.lineTo(p.x * canvasElement.width, p.y * canvasElement.height);
    }
    // Right side
    canvasCtx.moveTo(jawPoints[steps - 1].x * canvasElement.width, jawPoints[steps - 1].y * canvasElement.height);
    for (let r = 1; r < rows.length; r++) {
        const p = rows[r][steps - 1];
        canvasCtx.lineTo(p.x * canvasElement.width, p.y * canvasElement.height);
    }
    canvasCtx.stroke();
};

// --- 2D NECKLACE DRAWING ---
const necklaceSprite = new Image();
// Simple gold chain/necklace PNG
necklaceSprite.src = "https://pngimg.com/uploads/necklace/necklace_PNG68.png";

const drawNecklace2D = (faceLandmarks, poseLandmarks) => {
    // Shoulders: 11 (left), 12 (right)
    const leftShoulder = poseLandmarks[11];
    const rightShoulder = poseLandmarks[12];

    // Calculate Center
    const centerX = (leftShoulder.x + rightShoulder.x) / 2;
    const centerY = (leftShoulder.y + rightShoulder.y) / 2;

    // Calculate Width driven by distance between shoulders
    const dx = rightShoulder.x - leftShoulder.x;
    const dy = rightShoulder.y - leftShoulder.y;
    const shoulderDist = Math.sqrt(dx * dx + dy * dy);

    // Necklace Size & Position
    const width = shoulderDist * canvasElement.width * 0.7; // Much smaller, realistic fit
    const height = width * 1.0;

    // Position: Center X, Lower down on chest
    const x = centerX * canvasElement.width;
    // Move up significantly to sit on neck/chin area
    const y = centerY * canvasElement.height + (shoulderDist * canvasElement.height * -0.55);

    if (necklaceSprite.complete && necklaceSprite.naturalHeight !== 0) {
        canvasCtx.save();
        canvasCtx.translate(x, y);

        // Rotation (follow shoulder tilt)
        const angle = Math.atan2(dy, dx);
        canvasCtx.rotate(angle + Math.PI);

        // Draw centered
        canvasCtx.shadowColor = "rgba(0,0,0,0.3)";
        canvasCtx.shadowBlur = 10;

        // Draw image anchored top-center
        canvasCtx.drawImage(necklaceSprite, -width / 2, 0, width, height);

        canvasCtx.restore();
    }
};

// --- HAND MESH DRAWING ---
const drawTriangulatedHand = (landmarks) => {
    const meshColor = '#FFFFFF40'; // Transparent white
    const jointColor = '#D4AF37';  // Gold

    canvasCtx.strokeStyle = meshColor;
    canvasCtx.lineWidth = 0.5;
    canvasCtx.fillStyle = meshColor;

    // Helper for Linear Interpolation
    const lerp = (p1, p2, t) => ({
        x: p1.x + (p2.x - p1.x) * t,
        y: p1.y + (p2.y - p1.y) * t
    });

    // Helper: Fill space between two point-chains with a dense mesh
    const fillMesh = (chainA, chainB, numInterRows) => {
        // Generate rows
        const rows = [chainA];
        for (let r = 1; r <= numInterRows; r++) {
            const t = r / (numInterRows + 1);
            const row = [];
            // Assume proportional spacing
            const len = Math.max(chainA.length, chainB.length);
            for (let i = 0; i < len; i++) {
                // Get parameterized points
                const pA = chainA[Math.min(i, chainA.length - 1)];
                const pB = chainB[Math.min(i, chainB.length - 1)];
                row.push(lerp(pA, pB, t));
            }
            rows.push(row);
        }
        rows.push(chainB);

        // Draw Triangles
        for (let r = 0; r < rows.length - 1; r++) {
            const row1 = rows[r];
            const row2 = rows[r + 1];
            for (let i = 0; i < row1.length - 1; i++) {
                const p1 = row1[i];
                const p2 = row1[i + 1];
                const p3 = row2[i];
                const p4 = row2[i + 1];

                canvasCtx.beginPath();
                canvasCtx.moveTo(p1.x * canvasElement.width, p1.y * canvasElement.height);
                canvasCtx.lineTo(p2.x * canvasElement.width, p2.y * canvasElement.height);
                canvasCtx.lineTo(p3.x * canvasElement.width, p3.y * canvasElement.height);
                canvasCtx.stroke();

                canvasCtx.beginPath();
                canvasCtx.moveTo(p2.x * canvasElement.width, p2.y * canvasElement.height);
                canvasCtx.lineTo(p4.x * canvasElement.width, p4.y * canvasElement.height);
                canvasCtx.lineTo(p3.x * canvasElement.width, p3.y * canvasElement.height);
                canvasCtx.stroke();
            }
        }
    };

    // 1. Generate High-Res Finger Chains
    const fingers = [
        [1, 2, 3, 4],       // Thumb
        [5, 6, 7, 8],       // Index
        [9, 10, 11, 12],    // Middle
        [13, 14, 15, 16],   // Ring
        [17, 18, 19, 20]    // Pinky
    ];

    const fingerChains = [];
    fingers.forEach((indices, fingerIndex) => {
        const chain = [];
        // Add base
        if (fingerIndex === 0) {
            chain.push(landmarks[1]);
        } else {
            chain.push(landmarks[indices[0]]); // Knuckle
        }

        // Add joints
        for (let i = 0; i < indices.length - 1; i++) {
            const p1 = landmarks[indices[i]];
            const p2 = landmarks[indices[i + 1]];
            // Add intermediate points for curve
            for (let t = 0.2; t <= 0.8; t += 0.2) {
                chain.push(lerp(p1, p2, t));
            }
            chain.push(p2);
        }
        fingerChains.push({ chain, isRingFinger: fingerIndex === 3 });
    });

    // 5. Mesh the Palm
    const wrist = landmarks[0];
    const palmBaseIndices = [1, 5, 9, 13, 17];
    const palmBasePoints = palmBaseIndices.map(idx => landmarks[idx]);

    // Create rows from Wrist to Knuckles
    // Row 1: Wrist (expanded to width of hand base)
    const handWidth = landmarks[5].x - landmarks[17].x; // Approx width
    const wristLeft = { x: wrist.x + handWidth * 0.4, y: wrist.y };
    const wristRight = { x: wrist.x - handWidth * 0.4, y: wrist.y };
    const wristRow = [];
    for (let i = 0; i < 5; i++) {
        wristRow.push(lerp(wristRight, wristLeft, i / 4));
    }

    fillMesh(wristRow, palmBasePoints, 3);

    // 6. Mesh the Fingers (Webbing) - Highlight ring finger
    for (let i = 0; i < fingerChains.length - 1; i++) {
        const isRingFingerSegment = fingerChains[i].isRingFinger || fingerChains[i + 1].isRingFinger;

        // Change color for ring finger segments
        if (isRingFingerSegment) {
            canvasCtx.strokeStyle = '#00FFFF'; // Bright cyan for ring finger
        } else {
            canvasCtx.strokeStyle = meshColor;
        }

        fillMesh(fingerChains[i].chain, fingerChains[i + 1].chain, 1);

        // Reset to default color
        canvasCtx.strokeStyle = meshColor;
    }

    // 7. Draw Joints (Gold Dots)
    canvasCtx.fillStyle = jointColor;
    for (let i = 0; i < 21; i++) {
        const p = landmarks[i];
        canvasCtx.beginPath();
        canvasCtx.arc(p.x * canvasElement.width, p.y * canvasElement.height, 2, 0, 2 * Math.PI);
        canvasCtx.fill();
    }
};

function onResults(results) {
    if (!loadingOverlay.classList.contains('hidden')) {
        loadingOverlay.classList.add('hidden');
    }

    // Set canvas size to match video size
    canvasElement.width = videoElement.videoWidth;
    canvasElement.height = videoElement.videoHeight;

    canvasCtx.save();
    canvasCtx.clearRect(0, 0, canvasElement.width, canvasElement.height);

    // Mirroring is handled by CSS (transform: scaleX(-1))
    // So we draw normally here.
    // canvasCtx.translate(canvasElement.width, 0);
    // canvasCtx.scale(-1, 1);

    if (isMeshVisible) {
        // Draw Face Mesh
        if (results.faceLandmarks) {
            const meshColor = '#FFFFFF40';
            const featureColor = '#D4AF37';

            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_TESSELATION,
                { color: meshColor, lineWidth: 0.5 });

            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_RIGHT_EYE, { color: featureColor, lineWidth: 1 });
            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_RIGHT_EYEBROW, { color: featureColor, lineWidth: 1 });
            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_LEFT_EYE, { color: featureColor, lineWidth: 1 });
            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_LEFT_EYEBROW, { color: featureColor, lineWidth: 1 });
            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_FACE_OVAL, { color: '#FFFFFF80', lineWidth: 1 });
            drawConnectors(canvasCtx, results.faceLandmarks, FACEMESH_LIPS, { color: '#E5D3B3', lineWidth: 1 });
        }

        // Draw Neck Mesh
        if (results.faceLandmarks && results.poseLandmarks) {
            drawNeckMesh(results.faceLandmarks, results.poseLandmarks);
            drawNecklace2D(results.faceLandmarks, results.poseLandmarks); // <--- NEW NECKLACE CALL
        }

        // Draw Hand Mesh & Ring
        const drawHandAndRing = (landmarks) => {
            drawTriangulatedHand(landmarks);
            drawRing2D(landmarks); // <--- NEW 2D CALL
        };

        if (results.leftHandLandmarks) {
            drawHandAndRing(results.leftHandLandmarks);
        }
        if (results.rightHandLandmarks) {
            drawHandAndRing(results.rightHandLandmarks);
        }
    }
    canvasCtx.restore();
}
const holistic = new Holistic({
    locateFile: (file) => {
        return `https://cdn.jsdelivr.net/npm/@mediapipe/holistic/${file}`;
    }
});
holistic.setOptions({
    modelComplexity: 1,
    smoothLandmarks: true,
    enableSegmentation: false,
    smoothSegmentation: false,
    refineFaceLandmarks: true,
    minDetectionConfidence: 0.5,
    minTrackingConfidence: 0.5
});
holistic.onResults(onResults);

const camera = new Camera(videoElement, {
    onFrame: async () => {
        await holistic.send({ image: videoElement });
    },
    width: 1280,
    height: 720
});
camera.start();
