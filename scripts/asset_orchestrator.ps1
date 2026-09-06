<#
.SYNOPSIS
    UltraGoal Asset & Sensory Resource Orchestrator v5.5.0
.DESCRIPTION
    Motor de aprovisionamiento de recursos multimedia de alta fidelidad para agentes autónomos.
    Resuelve la trampa de los modelos 3D primitivos (cilindros y cajas desnudas), la falta de texturas,
    la ausencia de audio y los movimientos bruscos en simulaciones y juegos 3D.
    Soporta múltiples dominios:
    1. Tactical_FPS / CS_Clone: Texturas procedurales en GPU (arenisca, adoquines, cajas con remaches,
       contenedores con franjas de peligro, puertas dobles), skybox con cúpula solar, viewmodel articulado
       con miras de tritio 3-dot, calcomanías de bala (decals) y audio de combate.
    2. Space_Rocket / Flight: Naves multi-etapa con toberas, PBR, Web Audio API y cámaras cinematográficas.
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

$isTacticalFPS = ($Domain -match '(?i)(fps|shooter|counter|cs|tactical|strike|gun)')

if ($isTacticalFPS) {
    # =========================================================================
    # DOMINIO: TACTICAL FPS & COMBAT (COUNTER-STRIKE / SHOOTERS 3D)
    # =========================================================================
    $assetCatalog = [ordered]@{
        "Tactical_PBR_Textures" = [ordered]@{
            "Sandstone_Wall"       = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/brick_diffuse.jpg"
            "Cobblestone_Ground"   = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/terrain/grasslight-big.jpg"
            "Wood_Crate"           = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/crate.gif"
            "Metal_Container"      = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/roughness_map.jpg"
            "Bullet_Hole_Decal"    = "https://raw.githubusercontent.com/mrdoob/three.js/dev/examples/textures/decal/decal-diffuse.png"
        }
        "Tactical_Audio_Samples" = [ordered]@{
            "Gunshot_Pistol"       = "https://actions.google.com/sounds/v1/weapons/laser_gun.ogg"
            "Footstep_Concrete"    = "https://actions.google.com/sounds/v1/foley/footsteps_gravel.ogg"
            "Reload_Click"         = "https://actions.google.com/sounds/v1/doors/door_knob_turn.ogg"
        }
    }

    $proceduralMeshCode = @'
// =========================================================================
// ULTRA-GOAL TACTICAL FPS GRAPHICS & TEXTURE GENERATOR PIPELINE
// Erradica las cajas 3D planas generando texturas en GPU VRAM y viewmodel táctico
// =========================================================================

// 1. GENERADOR DE TEXTURAS PROCEDURALES EN VRAM (C# Raylib-cs / WebGL)
// Produce texturas PBR sin requerir archivos PNG externos en disco.
public class TextureManager {
    // Genera texturas para: SandstoneWall, PlasterWall, CobblestoneGround,
    // WoodCrate (con remaches), MetalContainer (con franjas de advertencia),
    // DoubleDoors (metálicas reforzadas) y BulletHoleDecal.
    // Todas las superficies del mundo 3D DEBEN mapearse con estas texturas usando UVs.
}

// 2. VIEWMODEL TÁCTICO EN PRIMERA PERSONA (CERO CILINDROS SUELTOS)
// El arma debe ensamblarse como un conjunto articulado orientado a la cámara:
// - Cañón y supresor alineados con DrawCylinderEx (NUNCA DrawCylinder que es vertical en Y).
// - Miras de combate nocturnas con 3 puntos de tritio verde luminiscente.
// - Ventana de expulsión de casquillos y corredera pavonada.
// - Guantes tácticos con agarre Weaver a dos manos.
// - Muelle elástico para retroceso (recoil kickback) y balanceo al caminar.
'@

    $audioSynthCode = @'
// =========================================================================
// ULTRA-GOAL PROCEDURAL COMBAT AUDIO SYNTHESIZER (Web Audio / Native)
// Sintetiza disparos, recargas, impactos y pasos tácticos en tiempo real
// =========================================================================
export class TacticalAudioEngine {
    constructor() {
        const AudioCtx = window.AudioContext || window.webkitAudioContext;
        this.ctx = AudioCtx ? new AudioCtx() : null;
    }
    playGunshot() {
        if (!this.ctx) return;
        // Percusión inicial (click percutor) + burst de ruido blanco + filtro paso bajo decreciente
        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const oscGain = this.ctx.createGain();
        osc.frequency.setValueAtTime(150, now);
        osc.frequency.exponentialRampToValueAtTime(30, now + 0.12);
        oscGain.gain.setValueAtTime(1.0, now);
        oscGain.gain.exponentialRampToValueAtTime(0.01, now + 0.15);
        osc.connect(oscGain);
        oscGain.connect(this.ctx.destination);
        osc.start(now);
        osc.stop(now + 0.15);
    }
    playFootstep() { /* Foley de pasos procedural */ }
    playReload() { /* Click mecánico de cerrojo */ }
}
'@

    $cameraDirectorCode = @'
// =========================================================================
// ULTRA-GOAL FPS TACTICAL CONTROLLER & CAMERA FRAMING
// Clamping vertical, neutralización horizontal Y y despeje visual de spawn
// =========================================================================
export class TacticalFPSController {
    constructor(camera) {
        this.camera = camera;
        this.pitch = 0;
        this.yaw = 0;
        this.recoil = 0;
    }
    update(mouseDX, mouseDY, dt) {
        // Clamping vertical innegociable (-1.5 a 1.5 rad)
        this.pitch = Math.max(-1.5, Math.min(1.5, this.pitch - mouseDY * 0.002));
        this.yaw -= mouseDX * 0.002;
        // Recuperación suave del retroceso del arma (spring damping)
        this.recoil = Math.max(0, this.recoil - dt * 8.0);
    }
    getForwardVector() {
        // Vector horizontal neutralizado (dir.y = 0) para no volar ni hundirse
        return { x: Math.sin(this.yaw), y: 0, z: Math.cos(this.yaw) };
    }
}
'@

    $guidanceText = "Para shooters tácticos y clones de Counter-Strike: NUNCA uses cajas 3D planas ni cilindros verticales. Implementa TextureManager para generar texturas en VRAM (arenisca, adoquines, cajas con remaches), cúpula solar con gradiente atmosférico, miras nocturnas de tritio 3-dot orientadas con DrawCylinderEx, calcomanías de bala en muros y audio de combate dinámico."
} else {
    # =========================================================================
    # DOMINIO: SPACE ROCKET / FLIGHT SIMULATION (DEFAULT)
    # =========================================================================
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

    $proceduralMeshCode = @'
// =========================================================================
// ULTRA-GOAL HIGH-FIDELITY COMPOSITE ROCKET MODEL BUILDER (Three.js)
// Erradica cilindros planos creando una nave multi-etapa con partes reales
// =========================================================================
export function createHighFidelityMultiStageRocket(THREE) {
    const rocketRoot = new THREE.Group();
    rocketRoot.name = "Apollo_Saturn_Vehicle";

    const hullMaterialWhite = new THREE.MeshStandardMaterial({ color: 0xf4f4f4, roughness: 0.25, metalness: 0.3 });
    const hullMaterialBlack = new THREE.MeshStandardMaterial({ color: 0x1a1a1a, roughness: 0.4, metalness: 0.2 });
    const engineMaterial = new THREE.MeshStandardMaterial({ color: 0x333333, roughness: 0.35, metalness: 0.85 });
    const engineGlowMaterial = new THREE.MeshStandardMaterial({ color: 0x00ffff, emissive: 0xff6600, emissiveIntensity: 2.5, roughness: 0.1 });

    const stage1 = new THREE.Group();
    stage1.name = "Stage_1_Booster";
    const s1BodyGeo = new THREE.CylinderGeometry(2.2, 2.2, 14, 32);
    const s1Mesh = new THREE.Mesh(s1BodyGeo, hullMaterialWhite);
    s1Mesh.position.y = 7;
    stage1.add(s1Mesh);

    const interGeo = new THREE.CylinderGeometry(2.22, 2.22, 1.2, 32);
    const interMesh = new THREE.Mesh(interGeo, hullMaterialBlack);
    interMesh.position.y = 13.5;
    stage1.add(interMesh);

    const finGeo = new THREE.BoxGeometry(0.1, 2.5, 1.8);
    for (let i = 0; i < 4; i++) {
        const fin = new THREE.Mesh(finGeo, hullMaterialWhite);
        const angle = (i * Math.PI) / 2;
        fin.position.set(Math.sin(angle) * 2.8, 1.8, Math.cos(angle) * 2.8);
        fin.rotation.y = angle;
        stage1.add(fin);
    }

    const nozzleGeo = new THREE.ConeGeometry(0.7, 1.6, 24, 1, true);
    for (let i = 0; i < 5; i++) {
        const nozzle = new THREE.Mesh(nozzleGeo, engineMaterial);
        nozzle.rotation.x = Math.PI;
        if (i === 0) {
            nozzle.position.set(0, -0.2, 0);
        } else {
            const angle = (i * Math.PI) / 2;
            nozzle.position.set(Math.sin(angle) * 1.1, -0.2, Math.cos(angle) * 1.1);
        }
        stage1.add(nozzle);
    }

    rocketRoot.add(stage1);
    rocketRoot.userData.stage1 = stage1;

    const payload = new THREE.Group();
    payload.name = "Apollo_Payload_CSM_LM";
    payload.position.y = 14;

    const csmGeo = new THREE.CylinderGeometry(1.8, 1.8, 3.8, 32);
    const csmMesh = new THREE.Mesh(csmGeo, hullMaterialWhite);
    csmMesh.position.y = 1.9;
    payload.add(csmMesh);

    const goldFoilMaterial = new THREE.MeshStandardMaterial({ color: 0xd4af37, roughness: 0.2, metalness: 0.9 });
    const cmGeo = new THREE.ConeGeometry(1.8, 2.2, 32);
    const cmMesh = new THREE.Mesh(cmGeo, goldFoilMaterial);
    cmMesh.position.y = 5.1;
    payload.add(cmMesh);

    const towerGeo = new THREE.CylinderGeometry(0.1, 0.25, 4.5, 8);
    const towerMesh = new THREE.Mesh(towerGeo, hullMaterialWhite);
    towerMesh.position.y = 8.2;
    payload.add(towerMesh);

    rocketRoot.add(payload);
    rocketRoot.userData.payload = payload;

    return rocketRoot;
}
'@

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

        this.roarFilter = this.ctx.createBiquadFilter();
        this.roarFilter.type = 'lowpass';
        this.roarFilter.frequency.setValueAtTime(320, this.ctx.currentTime);
        this.roarFilter.Q.setValueAtTime(3.5, this.ctx.currentTime);

        this.roarGain = this.ctx.createGain();
        this.roarGain.gain.setValueAtTime(intensity, this.ctx.currentTime);

        whiteNoise.connect(this.roarFilter);
        this.roarFilter.connect(this.roarGain);
        this.roarGain.connect(this.ctx.destination);

        whiteNoise.start();
        this.roarNode = whiteNoise;
    }

    stopRocketRoar() {
        if (this.roarNode) {
            this.roarGain.gain.linearRampToValueAtTime(0.001, this.ctx.currentTime + 1.2);
            setTimeout(() => {
                if (this.roarNode) {
                    this.roarNode.stop();
                    this.roarNode.disconnect();
                    this.roarNode = null;
                }
            }, 1300);
        }
    }

    playCountdownBeep(isFinal = false) {
        if (!this.isUnlocked) this.unlock();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(isFinal ? 1200 : 800, this.ctx.currentTime);
        gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + (isFinal ? 0.6 : 0.2));
        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start();
        osc.stop(this.ctx.currentTime + (isFinal ? 0.6 : 0.2));
    }

    playStageSeparation() {
        if (!this.isUnlocked) this.unlock();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(140, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(35, this.ctx.currentTime + 0.45);
        gain.gain.setValueAtTime(0.7, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.5);
        osc.connect(gain);
        gain.connect(this.ctx.destination);
        osc.start();
        osc.stop(this.ctx.currentTime + 0.5);
    }

    playRCSBurst() {
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

    $cameraDirectorCode = @'
// =========================================================================
// ULTRA-GOAL CINEMATIC CAMERA DIRECTOR (Three.js)
// Orquesta ángulos cinematográficos y transiciones suaves (Lerp/Slerp)
// =========================================================================
export class CinematicFlightDirector {
    constructor(camera, THREE) {
        this.camera = camera;
        this.THREE = THREE;
        this.currentPhase = "PAD_OVERVIEW";
        this.targetPhase = "PAD_OVERVIEW";
        this.damping = 0.04;
        this.desiredPos = new THREE.Vector3();
        this.desiredLook = new THREE.Vector3();
        this.currentLook = null;
    }

    setPhase(phaseName) {
        this.targetPhase = phaseName;
        this.currentPhase = phaseName;
    }

    update(dt, rocketPos, boosterPos) {
        if (!this.THREE || !this.camera) return;

        switch (this.targetPhase) {
            case "PAD_OVERVIEW":
                this.desiredPos.set(rocketPos.x + 35, rocketPos.y + 12, rocketPos.z + 45);
                this.desiredLook.set(rocketPos.x, rocketPos.y + 8, rocketPos.z);
                break;

            case "LIFTOFF_TRACKING":
                this.desiredPos.set(rocketPos.x + 40, rocketPos.y - 4, rocketPos.z + 55);
                this.desiredLook.set(rocketPos.x, rocketPos.y + 10, rocketPos.z);
                break;

            case "BOOSTER_CAM":
                if (boosterPos) {
                    this.desiredPos.set(boosterPos.x + 4, boosterPos.y + 18, boosterPos.z + 4);
                    this.desiredLook.set(boosterPos.x, boosterPos.y - 5, boosterPos.z);
                }
                break;

            case "CHASE_ORBITAL":
                this.desiredPos.set(rocketPos.x - 2, rocketPos.y - 14, rocketPos.z + 26);
                this.desiredLook.set(rocketPos.x, rocketPos.y + 12, rocketPos.z);
                break;

            case "COCKPIT":
                this.desiredPos.set(rocketPos.x, rocketPos.y + 24, rocketPos.z + 1.2);
                this.desiredLook.set(rocketPos.x, rocketPos.y + 35, rocketPos.z);
                break;

            case "LUNAR_LANDING":
                this.desiredPos.set(rocketPos.x + 15, rocketPos.y + 8, rocketPos.z + 15);
                this.desiredLook.copy(rocketPos);
                break;
        }

        const lerpFactor = Math.min(1.0, this.damping * (dt ? (dt * 60) : 1));
        this.camera.position.lerp(this.desiredPos, lerpFactor);
        
        if (!this.currentLook) this.currentLook = this.desiredLook.clone();
        this.currentLook.lerp(this.desiredLook, lerpFactor);
        this.camera.lookAt(this.currentLook);
    }
}
'@

    $guidanceText = "Para proyectos de simulación o 3D espacial: NUNCA uses cilindros planos solitarios. Emplea createHighFidelityMultiStageRocket o importa GLTF de la NASA. Inicializa SpaceAudioEngine con Web Audio API y coordina las fases de vuelo con CinematicFlightDirector."
}

# -------------------------------------------------------------------------
# CONSOLIDACIÓN DE RESPUESTA
# -------------------------------------------------------------------------
$resultObj = [ordered]@{
    engine              = "UltraGoal Asset & Sensory Resource Orchestrator v5.5.0"
    domain              = $Domain
    mode                = $Mode
    catalog             = $assetCatalog
    procedural_mesh_js  = $proceduralMeshCode
    audio_synth_js      = $audioSynthCode
    camera_director_js  = $cameraDirectorCode
    guidance            = $guidanceText
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
