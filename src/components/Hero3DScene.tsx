'use client';

import { useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Environment, Float, Sparkles, OrbitControls } from '@react-three/drei';
import * as THREE from 'three';

function GoldChainElement({ position }: { position: [number, number, number] }) {
    const meshRef = useRef<THREE.Mesh>(null);

    useFrame((state) => {
        if (!meshRef.current) return;
        meshRef.current.rotation.x = Math.sin(state.clock.elapsedTime * 0.5) * 0.2;
        meshRef.current.rotation.y += 0.01;
    });

    return (
        <Float speed={2} rotationIntensity={0.5} floatIntensity={1}>
            <mesh ref={meshRef} position={position}>
                <torusGeometry args={[1, 0.2, 16, 100]} />
                <meshPhysicalMaterial
                    color="#FFFFFF"
                    metalness={1}
                    roughness={0.1}
                    envMapIntensity={2}
                    clearcoat={0.3}
                    clearcoatRoughness={0.1}
                />
            </mesh>
        </Float>
    );
}

export default function Hero3DScene() {
    return (
        <div className="absolute inset-0 w-full h-full z-0 opacity-80 pointer-events-auto">
            <Canvas camera={{ position: [0, 0, 8], fov: 45 }}>
                <color attach="background" args={['#2A0845']} />

                <ambientLight intensity={0.5} />
                <directionalLight position={[10, 10, 5]} intensity={2} color="#FFFFFF" />
                <spotLight position={[-10, 10, 10]} angle={0.3} penumbra={1} intensity={3} color="#9333EA" />

                {/* Central animated gold links */}
                <GoldChainElement position={[-1, 1, 0]} />
                <GoldChainElement position={[1, -1, 0]} />

                {/* Floating dust/sparkles */}
                <Sparkles
                    count={200}
                    scale={12}
                    size={2}
                    speed={0.4}
                    opacity={0.3}
                    color="#FFFFFF"
                />

                <Environment preset="city" />
                <OrbitControls
                    enableZoom={false}
                    enablePan={false}
                    autoRotate
                    autoRotateSpeed={0.5}
                    maxPolarAngle={Math.PI / 2}
                    minPolarAngle={Math.PI / 2}
                />
            </Canvas>
        </div>
    );
}
