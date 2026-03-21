import SwiftUI

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ParticleSystem — Canvas + TimelineView particle effects
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
//  60fps Canvas-rendered particles for milestone celebrations.
//  Golden particles float upward and fade out.
//
//  Usage:
//  ```swift
//  ParticleSystem(isEmitting: $showCelebration)
//      .frame(width: 200, height: 200)
//  ```
//
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

struct ParticleSystem: View {
    @Binding var isEmitting: Bool
    var particleColor: Color = DS.Color.accent
    var particleCount: Int = 24

    @State private var particles: [Particle] = []
    @State private var lastUpdate: Date = .now
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            // Accessibility: just show a brief opacity flash
            Color.clear
                .overlay(
                    Circle()
                        .fill(particleColor.opacity(isEmitting ? 0.15 : 0))
                        .animation(.easeOut(duration: 0.3), value: isEmitting)
                )
        } else {
            TimelineView(.animation(paused: particles.isEmpty && !isEmitting)) { timeline in
                Canvas { context, size in
                    for particle in particles {
                        let rect = CGRect(
                            x: particle.x - particle.size / 2,
                            y: particle.y - particle.size / 2,
                            width: particle.size,
                            height: particle.size
                        )
                        context.opacity = particle.opacity
                        context.fill(
                            Circle().path(in: rect),
                            with: .color(particleColor)
                        )
                    }
                }
                .onChange(of: timeline.date) { _, now in
                    update(at: now)
                }
            }
            .onChange(of: isEmitting) { _, emitting in
                if emitting { emit() }
            }
        }
    }

    private func emit() {
        guard !reduceMotion else { return }
        let newParticles = (0..<particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: 20...180),
                y: CGFloat.random(in: 80...140),
                vx: CGFloat.random(in: -30...30),
                vy: CGFloat.random(in: -120 ... -40),
                size: CGFloat.random(in: 3...7),
                opacity: 1.0,
                life: 1.0,
                decay: Double.random(in: 0.4...0.9)
            )
        }
        particles.append(contentsOf: newParticles)
        lastUpdate = .now

        // Auto-stop emitting after burst
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(100))
            isEmitting = false
        }
    }

    private func update(at now: Date) {
        let dt = min(now.timeIntervalSince(lastUpdate), 0.05)
        lastUpdate = now

        particles = particles.compactMap { p in
            var p = p
            p.life -= dt * p.decay
            guard p.life > 0 else { return nil }

            p.x += p.vx * dt
            p.y += p.vy * dt
            p.vy += 40 * dt // slight gravity
            p.opacity = max(0, p.life)
            p.size *= (1.0 - dt * 0.3)
            return p
        }
    }
}

// MARK: - Particle Model

private struct Particle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var opacity: Double
    var life: Double      // 1.0 → 0.0
    var decay: Double     // how fast it fades
}

// MARK: - Preview

#Preview("ParticleSystem") {
    struct ParticlePreview: View {
        @State private var emitting = false

        var body: some View {
            ZStack {
                DS.Color.backgroundPrimary.ignoresSafeArea()

                ParticleSystem(isEmitting: $emitting)
                    .frame(width: 200, height: 200)

                Button("Burst") {
                    emitting = true
                }
                .font(DS.Typography.headline)
                .foregroundStyle(DS.Color.accent)
            }
        }
    }

    return ParticlePreview()
}
