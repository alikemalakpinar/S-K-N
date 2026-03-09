import SwiftUI

struct QiblaView: View {
    @State private var viewModel = QiblaViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                // Warm gradient background
                backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    if viewModel.hasLocation {
                        // Location label
                        if !viewModel.locationName.isEmpty {
                            Text(viewModel.locationName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(DS.Color.textSecondary)
                                .padding(.bottom, DS.Space.xl)
                        }

                        // Qibla indicator arrow above compass
                        qiblaTopIndicator
                            .padding(.bottom, DS.Space.sm)

                        // Compass
                        compassView
                            .padding(.horizontal, DS.Space.x2)

                        Spacer().frame(height: DS.Space.x3)

                        // Degree readout
                        degreeReadout

                        // Direction instruction
                        directionInstruction
                            .padding(.top, DS.Space.lg)

                    } else if viewModel.errorMessage != nil {
                        errorView
                    } else {
                        loadingView
                    }

                    Spacer()

                    // Calibration warning
                    if viewModel.isCalibrationNeeded {
                        calibrationBanner
                            .padding(.bottom, DS.Space.lg)
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
            .navigationTitle("Kıble")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { viewModel.start() }
            .onDisappear { viewModel.stop() }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                DS.Color.backgroundPrimary,
                DS.Color.backgroundPrimary,
                DS.Color.accent.opacity(0.04)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Qibla Top Indicator

    private var qiblaTopIndicator: some View {
        VStack(spacing: DS.Space.xs) {
            // Down-pointing triangle
            Image(systemName: "arrowtriangle.down.fill")
                .font(.system(size: 14))
                .foregroundStyle(DS.Color.accent)

            // Kaaba icon
            Text("🕋")
                .font(.system(size: 24))
        }
        .opacity(viewModel.isPointingAtQibla ? 1 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isPointingAtQibla)
    }

    // MARK: - Compass

    private var compassView: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - 20

            ZStack {
                // Compass circle
                Circle()
                    .stroke(DS.Color.accent.opacity(0.25), lineWidth: 1.5)
                    .frame(width: radius * 2, height: radius * 2)

                // Cardinal direction dots
                ForEach(0..<8, id: \.self) { i in
                    let angle = Double(i) * 45.0
                    let isPrimary = i % 2 == 0
                    Circle()
                        .fill(isPrimary ? DS.Color.textSecondary.opacity(0.5) : DS.Color.textSecondary.opacity(0.25))
                        .frame(width: isPrimary ? 6 : 4, height: isPrimary ? 6 : 4)
                        .offset(
                            x: radius * cos(CGFloat((angle - 90) * .pi / 180)),
                            y: radius * sin(CGFloat((angle - 90) * .pi / 180))
                        )
                }

                // Cardinal direction labels
                cardinalLabel("N", angle: 0, radius: radius + 20)
                cardinalLabel("S", angle: 180, radius: radius + 20)
                cardinalLabel("E", angle: 90, radius: radius + 20)
                cardinalLabel("W", angle: 270, radius: radius + 20)

                // Qibla needle
                qiblaNeedle(radius: radius)

                // Center dot
                Circle()
                    .fill(DS.Color.accent.opacity(0.8))
                    .frame(width: 16, height: 16)
                    .shadow(color: DS.Color.accent.opacity(0.3), radius: 6)
            }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(viewModel.compassRotation))
            .animation(.easeOut(duration: 0.15), value: viewModel.heading)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func cardinalLabel(_ text: String, angle: Double, radius: CGFloat) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(text == "N" ? DS.Color.accent : DS.Color.textPrimary)
            .offset(
                x: radius * cos(CGFloat((angle - 90) * .pi / 180)),
                y: radius * sin(CGFloat((angle - 90) * .pi / 180))
            )
            .rotationEffect(.degrees(-viewModel.compassRotation))
            .animation(.easeOut(duration: 0.15), value: viewModel.heading)
    }

    private func qiblaNeedle(radius: CGFloat) -> some View {
        ZStack {
            // Needle line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [DS.Color.accent.opacity(0.1), DS.Color.accent],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 3, height: radius - 10)
                .clipShape(Capsule())
                .offset(y: -(radius - 10) / 2)

            // Kaaba icon at tip
            Text("🕋")
                .font(.system(size: 20))
                .offset(y: -radius + 6)
                .rotationEffect(.degrees(-viewModel.qiblaDirection))
                .rotationEffect(.degrees(-viewModel.compassRotation))
                .animation(.easeOut(duration: 0.15), value: viewModel.heading)
        }
        .rotationEffect(.degrees(viewModel.qiblaDirection))
    }

    // MARK: - Degree Readout

    private var degreeReadout: some View {
        VStack(spacing: DS.Space.xs) {
            Text("\(Int(viewModel.qiblaDirection))\u{00B0}")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(DS.Color.textPrimary)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.2), value: Int(viewModel.qiblaDirection))

            Text("Kıble Yönü")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    // MARK: - Direction Instruction

    private var directionInstruction: some View {
        Group {
            if viewModel.isPointingAtQibla {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.green)
                    Text("Kıbleye dönüksünüz")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, DS.Space.xl)
                .padding(.vertical, DS.Space.md)
                .background(
                    Capsule()
                        .fill(.green.opacity(0.1))
                )
            } else {
                let absAngle = Int(abs(viewModel.rotationAngle))
                let direction = viewModel.rotationAngle > 0 ? "sağa" : "sola"

                Text("Telefonu \(absAngle)\u{00B0} \(direction) döndürün")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DS.Color.accent)
                    .padding(.horizontal, DS.Space.xl)
                    .padding(.vertical, DS.Space.md)
                    .background(
                        Capsule()
                            .fill(DS.Color.accentSoft)
                    )
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.2), value: absAngle)
            }
        }
    }

    // MARK: - Loading & Error

    private var loadingView: some View {
        VStack(spacing: DS.Space.lg) {
            ProgressView()
                .tint(DS.Color.accent)
                .scaleEffect(1.2)
            Text("Konum alınıyor...")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    private var errorView: some View {
        VStack(spacing: DS.Space.lg) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 44))
                .foregroundStyle(DS.Color.textSecondary)
            Text(viewModel.errorMessage ?? "Konum alınamadı")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Calibration Banner

    private var calibrationBanner: some View {
        HStack(spacing: DS.Space.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.orange)
            Text("Pusula kalibrasyonu gerekiyor. Telefonunuzu 8 şeklinde hareket ettirin.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DS.Color.textSecondary)
        }
        .padding(DS.Space.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DS.Color.cardElevated)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        )
    }
}
