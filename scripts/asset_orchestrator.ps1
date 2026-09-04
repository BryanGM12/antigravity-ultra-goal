<#
.SYNOPSIS
    UltraGoal Asset & Sensory Resource Orchestrator v5.0
.DESCRIPTION
    Motor de aprovisionamiento de recursos multimedia de alta fidelidad para agentes autónomos.
    Resuelve la trampa de los modelos 3D primitivos (cilindros y cajas desnudas), la falta de audio
    y los movimientos bruscos en simulaciones y animaciones.
    Proporciona:
    1. Catálogo de URLs de CDNs públicos verificados (NASA 3D Resources, texturas 4K de Solar System Scope, skyboxes HDR, modelos Three.js/Khronos).
    2. Generadores procedurales de mallas compuestas 3D listas para producción (cohetes multi-etapa con toberas, RCS, desacople, cápsula lunar).
    3. Motor de síntesis de audio procedural Web Audio API (rugido de motor, cuenta atrás, desacople, propulsores RCS).
    4. Director de cámaras cinematográficas con transiciones suaves (lerp/slerp).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Domain = "Space_Rocket",

    [Parameter(Mandatory = $false)]
    [ValidateSet("Catalog", "ProceduralMesh", "AudioSynth", "CameraDirector", "All")]
    [string]$Mode = "All",

    [Parameter(Mandatory = $false)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

# -------------------------------------------------------------------------
# 1. CATÁLOGO DE ASSETS VERIFICADOS (CDNs PÚBLICOS & NASA RESOURCES)
# -------------------------------------------------------------------------
$assetCatalog = [ordered]@{
    "Space_Solar_System" = [ordered]@{
        "Earth_Day_Texture"      = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_atmos_2048.jpg"
        "Earth_Normal_Map"       = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_normal_2048.jpg"
        "Earth_Specular_Map"     = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_specular_2048.jpg"
        "Earth_Clouds_Texture"   = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/earth_clouds_1024.png"
        "Moon_Texture"           = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/planets/moon_1024.jpg"
        "MilkyWay_Starfield"     = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/galaxy_starfield.png"
        "NASA_SolarSystemScope"  = "https://www.solarsystemscope.com/textures/"
        "NASA_3D_Models_Portal"  = "https://nasa3d.arc.nasa.gov/models"
    }
    "ThreeJS_Official_CDN" = [ordered]@{
        "Three_JS_Module"        = "https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.module.js"
        "GLTFLoader"             = "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/jsm/loaders/GLTFLoader.js"
        "OrbitControls"          = "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/jsm/controls/OrbitControls.js"
        "EffectComposer"         = "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/jsm/postprocessing/EffectComposer.js"
        "RenderPass"             = "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/jsm/postprocessing/RenderPass.js"
        "UnrealBloomPass"        = "https://cdn.jsdelivr.net/npm/three@0.128.0/examples/jsm/postprocessing/UnrealBloomPass.js"
    }
}

# -------------------------------------------------------------------------
# 2. GENERADOR PROCEDURAL DE MALLAS COMPUESTAS 3D (CERO TOY-DEMO CYLINDERS)
# -------------------------------------------------------------------------
$proceduralMeshCode = @'
// =========================================================================
// ULTRA-GOAL HIGH-FIDELITY COMPOSITE ROCKET MODEL BUILDER (Three.js)
// Erradica cilindros planos creando una nave multi-etapa con partes reales
// =========================================================================
export function createHighFidelityMultiStageRocket(THREE) {
    const rocketRoot = new THREE.Group();
    rocketRoot.name = "Apollo_Saturn_Vehicle";

    // Materiales PBR de Grado Aeroespacial
    const hullMaterialWhite = new THREE.MeshStandardMaterial({
        color: 0xf4f4f4,
        roughness: 0.25,
        metalness: 0.3
    });
    const hullMaterialBlack = new THREE.MeshStandardMaterial({
        color: 0x1a1a1a,
        roughness: 0.4,
        metalness: 0.2
    });
    const engineMaterial = new THREE.MeshStandardMaterial({
        color: 0x333333,
        roughness: 0.35,
        metalness: 0.85
    });
    const engineGlowMaterial = new THREE.MeshStandardMaterial({
        color: 0x00ffff,
        emissive: 0xff6600,
        emissiveIntensity: 2.5,
        roughness: 0.1
    });

    // ---------------------------------------------------------------------
    // ETAPA 1: PRIMER PROPULSOR BOOSTER (Desacoplable)
    // ---------------------------------------------------------------------
    const stage1 = new THREE.Group();
    stage1.name = "Stage_1_Booster";

    // Cuerpo cilíndrico con franjas de albedo aeroespacial
    const s1BodyGeo = new THREE.CylinderGeometry(2.2, 2.2, 14, 32);
    const s1Mesh = new THREE.Mesh(s1BodyGeo, hullMaterialWhite);
    s1Mesh.position.y = 7;
    stage1.add(s1Mesh);

    // Anillo interetapas oscuro
    const s1RingGeo = new THREE.CylinderGeometry(2.22, 2.22, 1.2, 32);
    const s1Ring = new THREE.Mesh(s1RingGeo, hullMaterialBlack);
    s1Ring.position.y = 13.4;
    stage1.add(s1Ring);

    // 4 Aletas aerodinámicas de estabilización
    for (let i = 0; i < 4; i++) {
        const angle = (i * Math.PI) / 2;
        const finGeo = new THREE.BoxGeometry(0.15, 2.5, 1.8);
        const fin = new THREE.Mesh(finGeo, hullMaterialBlack);
        fin.position.set(Math.cos(angle) * 2.8, 1.25, Math.sin(angle) * 2.8);
        fin.rotation.y = -angle;
        stage1.add(fin);
    }

    // 5 Toberas de motor de campana (Cluster F-1)
    const nozzlePositions = [
        [0, 0], [1.1, 0], [-1.1, 0], [0, 1.1], [0, -1.1]
    ];
    stage1.userData.nozzles = [];
    nozzlePositions.forEach(([nx, nz]) => {
        const coneGeo = new THREE.ConeGeometry(0.7, 1.6, 24, 1, true);
        const nozzle = new THREE.Mesh(coneGeo, engineMaterial);
        nozzle.rotation.x = Math.PI;
        nozzle.position.set(nx, -0.8, nz);
        stage1.add(nozzle);
        stage1.userData.nozzles.push(nozzle);

        // Disco incandescente interior
        const discGeo = new THREE.CircleGeometry(0.55, 16);
        const disc = new THREE.Mesh(discGeo, engineGlowMaterial);
        disc.rotation.x = Math.PI / 2;
        disc.position.set(nx, -0.75, nz);
        stage1.add(disc);
    });

    rocketRoot.add(stage1);
    rocketRoot.userData.stage1 = stage1;

    // ---------------------------------------------------------------------
    // ETAPA 2: SEGUNDA ETAPA Y PROPULSIÓN ORBITAL (Desacoplable)
    // ---------------------------------------------------------------------
    const stage2 = new THREE.Group();
    stage2.name = "Stage_2_Orbital";
    stage2.position.y = 14;

    const s2BodyGeo = new THREE.CylinderGeometry(2.0, 2.2, 9, 32);
    const s2Mesh = new THREE.Mesh(s2BodyGeo, hullMaterialWhite);
    s2Mesh.position.y = 4.5;
    stage2.add(s2Mesh);

    // Motor de vacío J-2
    const vacNozzleGeo = new THREE.ConeGeometry(1.1, 2.0, 24, 1, true);
    const vacNozzle = new THREE.Mesh(vacNozzleGeo, engineMaterial);
    vacNozzle.rotation.x = Math.PI;
    vacNozzle.position.y = -0.5;
    stage2.add(vacNozzle);

    rocketRoot.add(stage2);
    rocketRoot.userData.stage2 = stage2;

    // ---------------------------------------------------------------------
    // ETAPA 3: CÁPSULA APOLO / MÓDULO DE SERVICIO & TORRE DE SALVAMENTO
    // ---------------------------------------------------------------------
    const payload = new THREE.Group();
    payload.name = "Payload_Apollo_Capsule";
    payload.position.y = 23;

    // Módulo de servicio
    const smGeo = new THREE.CylinderGeometry(1.8, 2.0, 4, 32);
    const smMesh = new THREE.Mesh(smGeo, hullMaterialWhite);
    smMesh.position.y = 2;
    payload.add(smMesh);

    // Cono de la cápsula de mando (Command Module)
    const goldFoilMaterial = new THREE.MeshStandardMaterial({
        color: 0xd4af37,
        roughness: 0.3,
        metalness: 0.9
    });
    const cmGeo = new THREE.ConeGeometry(1.8, 2.2, 32);
    const cmMesh = new THREE.Mesh(cmGeo, goldFoilMaterial);
    cmMesh.position.y = 5.1;
    payload.add(cmMesh);

    // Torre de escape (Launch Escape Tower)
    const towerGeo = new THREE.CylinderGeometry(0.1, 0.25, 4.5, 8);
    const towerMesh = new THREE.Mesh(towerGeo, hullMaterialWhite);
    towerMesh.position.y = 8.2;
    payload.add(towerMesh);

    rocketRoot.add(payload);
    rocketRoot.userData.payload = payload;

    return rocketRoot;
}
'@

# -------------------------------------------------------------------------
# 3. MOTOR DE AUDIO PROCEDURAL NATIVO (WEB AUDIO API - CERO 404s)
# -------------------------------------------------------------------------
$audioSynthCode = @'
// =========================================================================
// ULTRA-GOAL PROCEDURAL WEB AUDIO SYNTHESIZER
// Genera paisajes sonoros de alta fidelidad sin archivos externos
// =========================================================================
export class SpaceAudioEngine {
    constructor() {
        this.ctx = null;
        this.isUnlocked = false;
        this.roarNode = null;
        this.roarGain = null;
        this.roarFilter = null;
    }

    unlock() {
        if (!this.ctx) {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            this.ctx = new AudioCtx();
        }
        if (this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
        this.isUnlocked = true;
    }

    // 1. Rugido de Motor de Cohete Continuo (Pink Noise + Low-Pass Filter Resonante)
    startRocketRoar(intensity = 0.8) {
        if (!this.isUnlocked) this.unlock();
        if (this.roarNode) return;

        const bufferSize = this.ctx.sampleRate * 2;
        const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const output = noiseBuffer.getChannelData(0);
        let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;

        for (let i = 0; i < bufferSize; i++) {
            const white = Math.random() * 2 - 1;
            b0 = 0.99886 * b0 + white * 0.0555179;
            b1 = 0.99332 * b1 + white * 0.0750759;
            b2 = 0.96900 * b2 + white * 0.1538520;
            b3 = 0.86650 * b3 + white * 0.3104856;
            b4 = 0.55000 * b4 + white * 0.5329522;
            b5 = -0.7616 * b5 - white * 0.0168980;
            output[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.11;
            b6 = white * 0.115926;
        }

        const whiteNoise = this.ctx.createBufferSource();
        whiteNoise.buffer = noiseBuffer;
        whiteNoise.loop = true;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(320, this.ctx.currentTime);
        filter.Q.setValueAtTime(4.0, this.ctx.currentTime);

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(intensity, this.ctx.currentTime);

        whiteNoise.connect(filter);
        filter.connect(gain);
        gain.connect(this.ctx.destination);

        whiteNoise.start(0);
        this.roarNode = whiteNoise;
        this.roarGain = gain;
        this.roarFilter = filter;
    }

    setRoarIntensity(thrust01) {
        if (!this.roarGain || !this.roarFilter) return;
        const cutoff = 150 + thrust01 * 850;
        this.roarFilter.frequency.setTargetAtTime(cutoff, this.ctx.currentTime, 0.1);
        this.roarGain.gain.setTargetAtTime(thrust01 * 0.9, this.ctx.currentTime, 0.1);
    }

    stopRocketRoar(fadeSec = 0.5) {
        if (!this.roarGain) return;
        this.roarGain.gain.setTargetAtTime(0.001, this.ctx.currentTime, fadeSec);
        setTimeout(() => {
            if (this.roarNode) {
                try { this.roarNode.stop(); } catch(e) {}
                this.roarNode.disconnect();
                this.roarNode = null;
            }
        }, fadeSec * 1000 + 100);
    }

    // 2. Beep de Cuenta Regresiva Estilo Apolo (Quindar Tone)
    playCountdownBeep(isFinal = false) {
        if (!this.isUnlocked) this.unlock();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(isFinal ? 1200 : 800, this.ctx.currentTime);

        gain.gain.setValueAtTime(0.3, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + (isFinal ? 0.4 : 0.15));

        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start();
        osc.stop(this.ctx.currentTime + 0.45);
    }

    // 3. Golpe de Desacople Mecánico / Pernos Explosivos (Staging Separation)
    playStagingSeparation() {
        if (!this.isUnlocked) this.unlock();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'triangle';
        osc.frequency.setValueAtTime(140, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(30, this.ctx.currentTime + 0.3);

        gain.gain.setValueAtTime(0.8, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.35);

        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start();
        osc.stop(this.ctx.currentTime + 0.4);
    }

    // 4. Silbido de Propulsor de Control de Reacción (RCS Thruster Puff)
    playRcsBurst() {
        if (!this.isUnlocked) this.unlock();
        const bufferSize = this.ctx.sampleRate * 0.15;
        const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (bufferSize * 0.3));
        }
        const noise = this.ctx.createBufferSource();
        noise.buffer = buffer;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(2400, this.ctx.currentTime);

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(0.35, this.ctx.currentTime);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(this.ctx.destination);
        noise.start();
    }
}
'@

# -------------------------------------------------------------------------
# 4. DIRECTOR DE CÁMARAS CINEMATOGRÁFICAS (SMOOTH EASING & MULTI-VIEW)
# -------------------------------------------------------------------------
$cameraDirectorCode = @'
// =========================================================================
// ULTRA-GOAL CINEMATIC CAMERA DIRECTOR (Three.js)
// Erradica saltos bruscos con transiciones suaves slerp/lerp
// =========================================================================
export class CinematicFlightDirector {
    constructor(camera, rocketObject) {
        this.camera = camera;
        this.target = rocketObject;
        this.currentMode = "PAD_TRACKING"; // PAD_TRACKING, BOOSTER_CAM, ORBITAL_CHASE, COCKPIT, LUNAR_LANDING
        this.damping = 0.05;

        this.desiredPos = new THREE.Vector3();
        this.desiredLook = new THREE.Vector3();
    }

    setMode(newMode) {
        this.currentMode = newMode;
    }

    update(dt) {
        if (!this.target) return;
        const rocketPos = this.target.position;

        switch(this.currentMode) {
            case "PAD_TRACKING":
                // Cámara fija en la torre de lanzamiento siguiendo con teleobjetivo
                this.desiredPos.set(40, 8, 40);
                this.desiredLook.copy(rocketPos);
                break;

            case "BOOSTER_CAM":
                // Cámara montada en el casco del cohete mirando hacia abajo a la Tierra
                this.desiredPos.set(rocketPos.x + 2.8, rocketPos.y + 12, rocketPos.z + 2.8);
                this.desiredLook.set(rocketPos.x, rocketPos.y - 30, rocketPos.z);
                break;

            case "ORBITAL_CHASE":
                // Cámara cinematográfica trasera en órbita
                this.desiredPos.set(rocketPos.x, rocketPos.y - 12, rocketPos.z + 28);
                this.desiredLook.copy(rocketPos);
                break;

            case "COCKPIT":
                // Vista interior/telemetría
                this.desiredPos.set(rocketPos.x, rocketPos.y + 24, rocketPos.z + 1.2);
                this.desiredLook.set(rocketPos.x, rocketPos.y + 35, rocketPos.z);
                break;

            case "LUNAR_LANDING":
                // Ángulo de descenso sobre la Luna
                this.desiredPos.set(rocketPos.x + 15, rocketPos.y + 8, rocketPos.z + 15);
                this.desiredLook.copy(rocketPos);
                break;
        }

        // Interpolación suave innegociable (Lerp) para evitar tirones
        const lerpFactor = Math.min(1.0, this.damping * (dt ? (dt * 60) : 1));
        this.camera.position.lerp(this.desiredPos, lerpFactor);
        
        // Control suave del punto de mira
        if (!this.currentLook) this.currentLook = this.desiredLook.clone();
        this.currentLook.lerp(this.desiredLook, lerpFactor);
        this.camera.lookAt(this.currentLook);
    }
}
'@

# -------------------------------------------------------------------------
# CONSOLIDACIÓN DE RESPUESTA
# -------------------------------------------------------------------------
$resultObj = [ordered]@{
    engine              = "UltraGoal Asset & Sensory Resource Orchestrator v5.0"
    domain              = $Domain
    mode                = $Mode
    catalog             = $assetCatalog
    procedural_mesh_js  = $proceduralMeshCode
    audio_synth_js      = $audioSynthCode
    camera_director_js  = $cameraDirectorCode
    guidance            = "Para proyectos de simulación o 3D: NUNCA uses cilindros planos solitarios. Emplea createHighFidelityMultiStageRocket o importa GLTF de la NASA. Inicializa SpaceAudioEngine con Web Audio API y coordina las fases de vuelo con CinematicFlightDirector."
}

$json = $resultObj | ConvertTo-Json -Depth 10

if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
    $parent = Split-Path $OutputPath -Parent
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($OutputPath, $json, [System.Text.Encoding]::UTF8)
}

Write-Output $json
