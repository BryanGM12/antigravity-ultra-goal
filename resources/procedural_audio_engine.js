/**
 * UltraGoal Procedural Audio Engine (Web Audio API)
 * Genera paisajes sonoros cinematográficos y efectos de audio en tiempo real
 * sin dependencias externas, archivos .mp3 ni riesgos de enlaces 404.
 */
export class ProceduralAudioEngine {
    constructor() {
        this.ctx = null;
        this.isUnlocked = false;
        this.activeEngines = new Map();
        this.masterGain = null;
    }

    /**
     * Desbloquea el contexto de audio tras la primera interacción de usuario
     * (cumpliendo con la política de autoplay de navegadores).
     */
    unlock() {
        if (!this.ctx) {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            this.ctx = new AudioCtx();
            this.masterGain = this.ctx.createGain();
            this.masterGain.gain.setValueAtTime(0.8, this.ctx.currentTime);
            this.masterGain.connect(this.ctx.destination);
        }
        if (this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
        this.isUnlocked = true;
    }

    /**
     * Inicia un rugido de cohete o turbina modulable con filtro resonante y pink noise.
     */
    startRocketRoar(id = "main_engine", initialThrust = 0.8) {
        if (!this.isUnlocked) this.unlock();
        if (this.activeEngines.has(id)) return;

        // Generar búfer de ruido rosa (pink noise) para graves profundos y realistas
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

        const source = this.ctx.createBufferSource();
        source.buffer = noiseBuffer;
        source.loop = true;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.setValueAtTime(250 + initialThrust * 750, this.ctx.currentTime);
        filter.Q.setValueAtTime(4.0, this.ctx.currentTime);

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(initialThrust, this.ctx.currentTime);

        source.connect(filter);
        filter.connect(gain);
        gain.connect(this.masterGain);

        source.start(0);
        this.activeEngines.set(id, { source, filter, gain });
    }

    /**
     * Modula la intensidad y frecuencia de corte del motor según el empuje (0.0 a 1.0)
     */
    setEngineThrust(id = "main_engine", thrust01 = 1.0) {
        const engine = this.activeEngines.get(id);
        if (!engine) return;
        const cutoff = 150 + thrust01 * 850;
        engine.filter.frequency.setTargetAtTime(cutoff, this.ctx.currentTime, 0.1);
        engine.gain.gain.setTargetAtTime(Math.max(0.001, thrust01 * 0.95), this.ctx.currentTime, 0.1);
    }

    /**
     * Detiene el motor con un desvanecimiento suave (fade out)
     */
    stopRocketRoar(id = "main_engine", fadeSec = 0.5) {
        const engine = this.activeEngines.get(id);
        if (!engine) return;
        engine.gain.gain.setTargetAtTime(0.001, this.ctx.currentTime, fadeSec);
        setTimeout(() => {
            try { engine.source.stop(); } catch(e) {}
            engine.source.disconnect();
            this.activeEngines.delete(id);
        }, fadeSec * 1000 + 100);
    }

    /**
     * Beep de cuenta regresiva o quindar tone de la NASA
     */
    playCountdownBeep(isFinal = false) {
        if (!this.isUnlocked) this.unlock();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(isFinal ? 1200 : 800, this.ctx.currentTime);

        gain.gain.setValueAtTime(0.35, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + (isFinal ? 0.4 : 0.15));

        osc.connect(gain);
        gain.connect(this.masterGain);
        osc.start();
        osc.stop(this.ctx.currentTime + 0.45);
    }

    /**
     * Impacto seco de desacople de etapas o pernos explosivos
     */
    playStagingClank() {
        if (!this.isUnlocked) this.unlock();
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'triangle';
        osc.frequency.setValueAtTime(160, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(25, this.ctx.currentTime + 0.35);

        gain.gain.setValueAtTime(0.9, this.ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.4);

        osc.connect(gain);
        gain.connect(this.masterGain);
        osc.start();
        osc.stop(this.ctx.currentTime + 0.45);
    }

    /**
     * Silbido de ráfaga de propulsor RCS para maniobras espaciales
     */
    playRcsPuff() {
        if (!this.isUnlocked) this.unlock();
        const bufferSize = this.ctx.sampleRate * 0.18;
        const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (bufferSize * 0.3));
        }
        const noise = this.ctx.createBufferSource();
        noise.buffer = buffer;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(2800, this.ctx.currentTime);
        filter.Q.setValueAtTime(2.0, this.ctx.currentTime);

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(0.4, this.ctx.currentTime);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(this.masterGain);
        noise.start();
    }
}
