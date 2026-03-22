import SwiftUI

/// A visual sun arc showing the day's progression with prayer time markers.
///
/// Renders a half-circle arc from sunrise to sunset, with a sun indicator
/// at the current position and prayer time dots along the arc.
struct SunArcView: View {
    let sunrise: Date
    let sunset: Date
    let prayerMarkers: [(String, Date)] // (label, time)

    private let arcHeight: CGFloat = 120

    private var dayProgress: Double {
        let now = Date()
        guard sunrise < sunset else { return 0 }
        let total = sunset.timeIntervalSince(sunrise)
        let elapsed = now.timeIntervalSince(sunrise)
        return min(max(elapsed / total, 0), 1)
    }

    private var isDaytime: Bool {
        let now = Date()
        return now >= sunrise && now <= sunset
    }

    var body: some View {
        VStack(spacing: DS.Space.md) {
            // Arc
            GeometryReader { geo in
                let w = geo.size.width
                let h = arcHeight

                ZStack {
                    // Ambient glow behind arc area
                    if isDaytime {
                        RadialGradient(
                            colors: [
                                DS.Color.accent.opacity(0.06),
                                .clear
                            ],
                            center: UnitPoint(x: dayProgress, y: 0.3),
                            startRadius: 10,
                            endRadius: 120
                        )
                        .frame(height: h)
                        .allowsHitTesting(false)
                    }

                    // Track arc (dashed)
                    ArcShape()
                        .stroke(
                            DS.Color.hairline,
                            style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                        )
                        .frame(height: h)

                    // Glow trail behind filled arc
                    if isDaytime {
                        ArcShape()
                            .trim(from: 0, to: dayProgress)
                            .stroke(
                                DS.Color.accent.opacity(0.15),
                                lineWidth: 10
                            )
                            .blur(radius: 6)
                            .frame(height: h)

                        // Filled arc up to current time — multi-stop gradient
                        ArcShape()
                            .trim(from: 0, to: dayProgress)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        DS.Color.accent.opacity(0.2),
                                        DS.Color.accent.opacity(0.6),
                                        DS.Color.accent
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                            )
                            .frame(height: h)
                    }

                    // Prayer markers with labels
                    ForEach(prayerMarkers, id: \.0) { label, time in
                        let progress = markerProgress(for: time)
                        if progress >= 0, progress <= 1 {
                            let point = arcPoint(progress: progress, width: w, height: h)

                            // Marker dot
                            Circle()
                                .fill(DS.Color.accent.opacity(0.4))
                                .frame(width: 6, height: 6)
                                .overlay(
                                    Circle()
                                        .stroke(DS.Color.accent.opacity(0.2), lineWidth: 1)
                                )
                                .position(point)

                            // Marker label
                            Text(label)
                                .font(.system(size: 8, weight: .bold, design: .rounded))
                                .foregroundStyle(DS.Color.textSecondary.opacity(0.6))
                                .position(
                                    CGPoint(
                                        x: point.x,
                                        y: min(point.y + 12, h - 2)
                                    )
                                )
                        }
                    }

                    // Sun indicator with glow halo
                    if isDaytime {
                        let sunPoint = arcPoint(progress: dayProgress, width: w, height: h)

                        // Outer glow
                        Circle()
                            .fill(DS.Color.accent.opacity(0.15))
                            .frame(width: 28, height: 28)
                            .blur(radius: 6)
                            .position(sunPoint)

                        // Sun body
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [DS.Color.accent, DS.Color.accent.opacity(0.8)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 7
                                )
                            )
                            .frame(width: 14, height: 14)
                            .shadow(color: DS.Color.accent.opacity(0.5), radius: 8)
                            .position(sunPoint)
                    }

                    // Horizon line with gradient fade
                    LinearGradient(
                        colors: [
                            DS.Color.hairline.opacity(0),
                            DS.Color.hairline,
                            DS.Color.hairline,
                            DS.Color.hairline.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 1)
                    .offset(y: h / 2 - 0.5)
                }
            }
            .frame(height: arcHeight)

            // Sunrise / Sunset labels
            HStack {
                HStack(spacing: DS.Space.xs) {
                    Image(systemName: "sunrise.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DS.Color.accent, DS.Color.warning.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text(sunrise, format: .dateTime.hour().minute())
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textSecondary)
                }

                Spacer()

                // Day duration
                let dayDuration = sunset.timeIntervalSince(sunrise) / 3600
                Text(String(format: "%.0fsa %02ddk", dayDuration, Int(dayDuration.truncatingRemainder(dividingBy: 1) * 60)))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(DS.Color.textTertiary)

                Spacer()

                HStack(spacing: DS.Space.xs) {
                    Text(sunset, format: .dateTime.hour().minute())
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(DS.Color.textSecondary)
                    Image(systemName: "sunset.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DS.Color.warning, DS.Color.accent.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
            }
        }
    }

    // MARK: - Geometry Helpers

    private func markerProgress(for time: Date) -> Double {
        let total = sunset.timeIntervalSince(sunrise)
        guard total > 0 else { return 0 }
        return time.timeIntervalSince(sunrise) / total
    }

    private func arcPoint(progress: Double, width: CGFloat, height: CGFloat) -> CGPoint {
        let angle = Double.pi * (1 - progress) // pi to 0 (left to right)
        let radius = width / 2
        let centerX = width / 2
        let centerY = height
        return CGPoint(
            x: centerX + radius * cos(angle),
            y: centerY - abs(radius * sin(angle)) * (height / radius)
        )
    }
}

// MARK: - Arc Shape

private struct ArcShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let radius = rect.width / 2
        let scaleY = rect.height / radius

        // Draw a semi-ellipse
        let steps = 60
        for i in 0...steps {
            let angle = Double.pi * (1 - Double(i) / Double(steps))
            let x = center.x + radius * cos(angle)
            let y = center.y - abs(radius * sin(angle)) * scaleY
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

// MARK: - Preview

#Preview("SunArcView") {
    let cal = Calendar.current
    let today = cal.startOfDay(for: Date())
    let sunrise = cal.date(bySettingHour: 6, minute: 30, second: 0, of: today)!
    let sunset = cal.date(bySettingHour: 18, minute: 45, second: 0, of: today)!

    SunArcView(
        sunrise: sunrise,
        sunset: sunset,
        prayerMarkers: [
            ("F", cal.date(bySettingHour: 5, minute: 15, second: 0, of: today)!),
            ("D", cal.date(bySettingHour: 12, minute: 30, second: 0, of: today)!),
            ("A", cal.date(bySettingHour: 16, minute: 0, second: 0, of: today)!),
            ("M", cal.date(bySettingHour: 18, minute: 45, second: 0, of: today)!),
            ("I", cal.date(bySettingHour: 20, minute: 15, second: 0, of: today)!),
        ]
    )
    .padding(DS.Space.xl)
    .background(DS.Color.backgroundPrimary)
}
