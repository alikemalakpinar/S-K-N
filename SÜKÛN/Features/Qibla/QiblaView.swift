import SwiftUI

struct QiblaView: View {
    @State private var viewModel = QiblaViewModel()
    @State private var glowPulse = false
    @State private var appeared = false
    @State private var lockRingScale: CGFloat = 0.5
    @State private var lockRingOpacity: Double = 0

    // Compass geometry
    private let compassSize: CGFloat = 280

    var body: some View {
        NavigationStack {
            ZStack {
                DS.Color.backgroundPrimary.ignoresSafeArea()

                // Green ambient glow when locked
                // Lock celebration rings
                ZStack {
                    Circle()
                        .stroke(DS.Color.success.opacity(lockRingOpacity), lineWidth: 2)
                        .scaleEffect(lockRingScale)
                        .frame(width: 80, height: 80)
                    Circle()
                        .stroke(DS.Color.success.opacity(lockRingOpacity * 0.6), lineWidth: 1.5)
                        .scaleEffect(lockRingScale * 0.8)
                        .frame(width: 120, height: 120)
                }
                .allowsHitTesting(false)

                if viewModel.isLockedOnQibla {
                    RadialGradient(
                        colors: [
                            DS.Color.success.opacity(0.12),
                            DS.Color.success.opacity(0.04),
                            .clear
                        ],
                        center: .center,
                        startRadius: 40,
                        endRadius: 300
                    )
                    .ignoresSafeArea()
                    .transition(.opacity)
                }

                VStack(spacing: 0) {
                    Spacer()

                    if viewModel.hasLocation {
                        // Location
                        if !viewModel.locationName.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 9))
                                Text(viewModel.locationName)
                                    .font(DS.Typography.alongSans(size: 13, weight: "Medium"))
                            }
                            .foregroundStyle(DS.Color.textSecondary)
                            .padding(.bottom, DS.Space.x3)
                            .dsAppear(loaded: appeared, index: 0)
                        }

                        // Fixed Qibla indicator above compass
                        qiblaIndicator
                            .padding(.bottom, DS.Space.md)
                            .dsAppear(loaded: appeared, index: 1)

                        // Compass dial
                        compassDial
                            .dsAppear(loaded: appeared, index: 2)

                        Spacer().frame(height: DS.Space.x3)

                        // Degree readout
                        degreeReadout
                            .dsAppear(loaded: appeared, index: 3)

                        // Direction pill
                        directionPill
                            .padding(.top, DS.Space.lg)
                            .dsAppear(loaded: appeared, index: 4)

                    } else if viewModel.errorMessage != nil {
                        errorView
                    } else {
                        loadingView
                    }

                    Spacer()

                    // Accuracy badge
                    if viewModel.accuracy > 0 && viewModel.hasLocation {
                        accuracyBadge
                            .padding(.bottom, DS.Space.sm)
                    }

                    // Calibration warning
                    if viewModel.isCalibrationNeeded {
                        calibrationBanner
                            .padding(.bottom, DS.Space.lg)
                    }
                }
                .padding(.horizontal, DS.Space.lg)
            }
            .navigationTitle(L10n.Qibla.title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.start()
                DS.Haptic.prepare()
                withAnimation(DS.Motion.slowReveal) {
                    appeared = true
                }
            }
            .onDisappear { viewModel.stop() }
            .onChange(of: viewModel.didJustLock) { _, locked in
                if locked {
                    DS.Haptic.qiblaLocked()
                    viewModel.consumeLockEvent()
                    // Start glow pulse
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                    // Lock celebration expanding rings
                    lockRingScale = 0.5
                    lockRingOpacity = 0.7
                    withAnimation(.easeOut(duration: 1.0)) {
                        lockRingScale = 3.5
                        lockRingOpacity = 0
                    }
                }
            }
            .onChange(of: viewModel.isLockedOnQibla) { _, locked in
                if !locked {
                    withAnimation(.easeOut(duration: 0.3)) {
                        glowPulse = false
                    }
                }
            }
        }
    }

    // MARK: - Qibla Indicator (fixed above compass)

    private var qiblaIndicator: some View {
        VStack(spacing: 6) {
            Image(systemName: "arrow.down")
                .font(DS.Typography.alongSans(size: 16, weight: "Bold"))
                .foregroundStyle(viewModel.isLockedOnQibla ? DS.Color.success : DS.Color.accent)
                .animation(DS.Motion.standard, value: viewModel.isLockedOnQibla)

            Image(systemName: "building.columns.fill")
                .font(.system(size: 22))
                .foregroundStyle(viewModel.isLockedOnQibla ? DS.Color.success : DS.Color.accent)
                .symbolEffect(.pulse, options: .repeating, isActive: viewModel.isLockedOnQibla)
        }
    }

    // MARK: - Compass Dial

    private var compassDial: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    viewModel.isLockedOnQibla
                        ? DS.Color.success.opacity(0.35)
                        : DS.Color.hairline,
                    lineWidth: 1.5
                )
                .frame(width: compassSize, height: compassSize)
                .shadow(
                    color: viewModel.isLockedOnQibla
                        ? DS.Color.success.opacity(glowPulse ? 0.4 : 0.15)
                        : .clear,
                    radius: glowPulse ? 24 : 12
                )
                .animation(.easeInOut(duration: 1.2), value: glowPulse)

            // Inner content rotates with compass
            ZStack {
                // Tick marks — 72 ticks (every 5°)
                ForEach(0..<72, id: \.self) { i in
                    let angle = Double(i) * 5.0
                    let isCardinal = i % 18 == 0         // N, E, S, W
                    let isIntercardinal = i % 9 == 0     // NE, SE, SW, NW
                    let isMajor = i % 18 == 0 || i % 9 == 0

                    Rectangle()
                        .fill(
                            isCardinal
                                ? DS.Color.textPrimary.opacity(0.6)
                                : isMajor
                                    ? DS.Color.textSecondary.opacity(0.3)
                                    : DS.Color.hairline
                        )
                        .frame(
                            width: isCardinal ? 2 : 1,
                            height: isCardinal ? 14 : (isIntercardinal ? 10 : 6)
                        )
                        .offset(y: -(compassSize / 2 - (isCardinal ? 7 : 5)))
                        .rotationEffect(.degrees(angle))
                }

                // Cardinal labels
                cardinalLabel("N", angle: 0, isNorth: true)
                cardinalLabel("E", angle: 90, isNorth: false)
                cardinalLabel("S", angle: 180, isNorth: false)
                cardinalLabel("W", angle: 270, isNorth: false)

                // Qibla needle
                qiblaNeedle
            }
            .rotationEffect(.degrees(viewModel.compassRotation))
            .animation(DS.Motion.elastic, value: viewModel.heading)

            // Center dot
            Circle()
                .fill(
                    viewModel.isLockedOnQibla
                        ? DS.Color.success
                        : DS.Color.accent
                )
                .frame(width: 10, height: 10)
                .shadow(
                    color: viewModel.isLockedOnQibla
                        ? DS.Color.success.opacity(0.5)
                        : DS.Color.accent.opacity(0.3),
                    radius: 6
                )
                .animation(DS.Motion.standard, value: viewModel.isLockedOnQibla)
        }
        .frame(width: compassSize + 40, height: compassSize + 40)
    }

    private func cardinalLabel(_ text: String, angle: Double, isNorth: Bool) -> some View {
        let radius = compassSize / 2 - 30
        return Text(text)
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundStyle(
                isNorth
                    ? (viewModel.isLockedOnQibla ? DS.Color.success : DS.Color.accent)
                    : DS.Color.textSecondary
            )
            .offset(
                x: radius * cos(CGFloat((angle - 90) * .pi / 180)),
                y: radius * sin(CGFloat((angle - 90) * .pi / 180))
            )
            // Counter-rotate so labels stay upright
            .rotationEffect(.degrees(-viewModel.compassRotation))
            .animation(DS.Motion.elastic, value: viewModel.heading)
    }

    private var qiblaNeedle: some View {
        let needleLength = compassSize / 2 - 38
        let needleColor = viewModel.isLockedOnQibla ? DS.Color.success : DS.Color.accent

        return ZStack {
            // Glow trail behind needle
            Capsule()
                .fill(needleColor.opacity(0.15))
                .frame(width: 10, height: needleLength)
                .blur(radius: 6)
                .offset(y: -needleLength / 2)

            // Needle body — tapered gradient
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            needleColor.opacity(0.05),
                            needleColor.opacity(0.4),
                            needleColor
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 3, height: needleLength)
                .offset(y: -needleLength / 2)

            // Needle tip — diamond with glow
            ZStack {
                Image(systemName: "diamond.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(needleColor.opacity(0.3))
                    .blur(radius: 4)
                Image(systemName: "diamond.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(needleColor)
            }
            .offset(y: -needleLength - 2)

            // Kaaba icon at needle tip
            Image(systemName: "building.columns.fill")
                .font(.system(size: 8))
                .foregroundStyle(needleColor.opacity(0.6))
                .offset(y: -needleLength - 16)
        }
        .rotationEffect(.degrees(viewModel.qiblaDirection))
    }

    // MARK: - Degree Readout

    private var degreeReadout: some View {
        VStack(spacing: DS.Space.sm) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(Int(viewModel.qiblaDirection))")
                    .font(.system(size: 60, weight: .ultraLight, design: .rounded))
                    .foregroundStyle(
                        viewModel.isLockedOnQibla ? DS.Color.success : DS.Color.textPrimary
                    )
                    .contentTransition(.numericText())
                    .animation(DS.Motion.countdown, value: Int(viewModel.qiblaDirection))

                Text("°")
                    .font(.system(size: 28, weight: .ultraLight, design: .rounded))
                    .foregroundStyle(DS.Color.textSecondary.opacity(0.5))
            }

            Text(L10n.Qibla.direction)
                .font(DS.Typography.sectionHead)
                .foregroundStyle(DS.Color.textSecondary)
                .tracking(3)
                .textCase(.uppercase)
        }
    }

    // MARK: - Direction Pill

    private var directionPill: some View {
        Group {
            if viewModel.isLockedOnQibla {
                HStack(spacing: DS.Space.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text(L10n.Qibla.lockedOn)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(DS.Color.success)
                .padding(.horizontal, DS.Space.xl)
                .padding(.vertical, DS.Space.md)
                .background(
                    Capsule()
                        .fill(DS.Color.success.opacity(0.12))
                        .overlay(
                            Capsule()
                                .stroke(DS.Color.success.opacity(0.2), lineWidth: 0.5)
                        )
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            } else {
                let absAngle = Int(abs(viewModel.rotationAngle))
                let direction = viewModel.rotationAngle > 0 ? L10n.Qibla.right : L10n.Qibla.left

                HStack(spacing: DS.Space.sm) {
                    Image(systemName: viewModel.rotationAngle > 0
                          ? "arrow.turn.right.up"
                          : "arrow.turn.left.up")
                        .font(DS.Typography.alongSans(size: 14, weight: "Medium"))
                    Text("\(absAngle)° \(direction)")
                        .font(.system(size: 14, weight: .semibold))
                        .contentTransition(.numericText())
                }
                .foregroundStyle(DS.Color.accent)
                .padding(.horizontal, DS.Space.xl)
                .padding(.vertical, DS.Space.md)
                .background(
                    Capsule()
                        .fill(DS.Color.accentSoft)
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
        }
        .animation(DS.Motion.standard, value: viewModel.isLockedOnQibla)
    }

    // MARK: - Accuracy Badge

    private var accuracyBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(viewModel.accuracy < 15 ? DS.Color.success : DS.Color.warning)
                .frame(width: 5, height: 5)
            Text("±\(Int(viewModel.accuracy))°")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    // MARK: - Loading & Error

    private var loadingView: some View {
        VStack(spacing: DS.Space.lg) {
            DSSkeleton.circle(size: 48)
            Text(L10n.Qibla.locationLoading)
                .font(DS.Typography.bodyMedium)
                .foregroundStyle(DS.Color.textSecondary)
        }
    }

    private var errorView: some View {
        SKNErrorState(
            icon: "location.slash.fill",
            message: viewModel.errorMessage ?? L10n.Qibla.locationFailed
        )
    }

    // MARK: - Calibration Banner

    private var calibrationBanner: some View {
        DSAlert(
            L10n.Qibla.calibrationNeeded,
            title: L10n.Qibla.calibrationTitle,
            variant: .warning
        )
    }
}

// MARK: - Preview

#Preview("Qibla") {
    QiblaView()
}
