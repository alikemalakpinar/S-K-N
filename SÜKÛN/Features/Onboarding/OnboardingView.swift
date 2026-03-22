import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    let container: DependencyContainer

    @State private var currentPage = 0
    @State private var locationGranted = false
    @State private var notificationGranted = false
    @State private var selectedMethod = "Turkey"
    @State private var iconFloating = false
    @State private var appeared = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            DS.Color.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Page dots at top
                pageDots
                    .padding(.top, DS.Space.x2)

                // Content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    locationPage.tag(1)
                    notificationPage.tag(2)
                    readyPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)

                // Bottom button
                bottomButton
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.x3)
                    .scaleEffect(appeared ? 1 : 0.9)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: appeared)
            }
        }
    }

    // MARK: - Page Dots

    private var pageDots: some View {
        HStack(spacing: DS.Space.sm) {
            ForEach(0..<totalPages, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? DS.Color.accent : DS.Color.hairline)
                    .frame(width: i == currentPage ? 24 : 8, height: 4)
                    .animation(.easeOut(duration: 0.3), value: currentPage)
            }
        }
    }

    // MARK: - Welcome Page

    private var welcomePage: some View {
        VStack(spacing: 0) {
            Spacer()

            // Ornamental geometric pattern
            ZStack {
                // Outer ring — slow rotation
                Circle()
                    .stroke(DS.Color.accent.opacity(0.15), lineWidth: 1)
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(appeared ? 360 : 0))
                    .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: appeared)

                Circle()
                    .stroke(DS.Color.accent.opacity(0.1), lineWidth: 1)
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(appeared ? -360 : 0))
                    .animation(.linear(duration: 80).repeatForever(autoreverses: false), value: appeared)

                // Moon crescent
                ZStack {
                    Circle()
                        .fill(DS.Color.accent.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "moon.stars.fill")
                        .font(DS.Typography.alongSans(size: 48, weight: "Regular"))
                        .foregroundStyle(DS.Color.accent)
                        .offset(y: iconFloating ? -4 : 4)
                        .animation(
                            .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                            value: iconFloating
                        )
                }
            }
            .scaleEffect(appeared ? 1 : 0.6)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.65), value: appeared)

            Spacer().frame(height: DS.Space.x4)

            // App name
            Text("Sükûn")
                .font(DS.Typography.displayHero)
                .foregroundStyle(DS.Color.textPrimary)
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.15), value: appeared)

            Spacer().frame(height: DS.Space.md)

            // Tagline
            Text("Huzurlu bir ibadet deneyimi")
                .font(DS.Typography.displayBody)
                .foregroundStyle(DS.Color.textSecondary)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.3), value: appeared)

            Spacer()
            Spacer()
        }
        .onAppear {
            appeared = true
            iconFloating = true
        }
    }

    // MARK: - Location Page

    private var locationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon with floating effect
            ZStack {
                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 120, height: 120)
                Image(systemName: "location.fill")
                    .font(DS.Typography.alongSans(size: 48, weight: "Regular"))
                    .foregroundStyle(DS.Color.accent)
                    .offset(y: iconFloating ? -3 : 3)
                    .animation(
                        .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                        value: iconFloating
                    )
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 0.7).combined(with: .opacity),
                removal: .scale(scale: 1.1).combined(with: .opacity)
            ))

            Spacer().frame(height: DS.Space.x3)

            Text("Konum Erişimi")
                .font(DS.Typography.displayTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer().frame(height: DS.Space.md)

            Text("Namaz vakitlerini ve kıble yönünü\ndoğru hesaplayabilmemiz için\nkonumunuza ihtiyacımız var.")
                .font(DS.Typography.alongSans(size: 16, weight: "Regular"))
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: DS.Space.x2)

            if locationGranted {
                Label("Konum izni verildi", systemImage: "checkmark.circle.fill")
                    .font(DS.Typography.bodyMedium)
                    .foregroundStyle(DS.Color.success)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Space.x2)
    }

    // MARK: - Notification Page

    private var notificationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon with floating effect
            ZStack {
                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 120, height: 120)
                Image(systemName: "bell.badge.fill")
                    .font(DS.Typography.alongSans(size: 48, weight: "Regular"))
                    .foregroundStyle(DS.Color.accent)
                    .offset(y: iconFloating ? -3 : 3)
                    .animation(
                        .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                        value: iconFloating
                    )
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 0.7).combined(with: .opacity),
                removal: .scale(scale: 1.1).combined(with: .opacity)
            ))

            Spacer().frame(height: DS.Space.x3)

            Text("Bildirimler")
                .font(DS.Typography.displayTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer().frame(height: DS.Space.md)

            Text("Namaz vakti geldiğinde\nsizi haberdar edelim.")
                .font(DS.Typography.alongSans(size: 16, weight: "Regular"))
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: DS.Space.x2)

            if notificationGranted {
                Label("Bildirim izni verildi", systemImage: "checkmark.circle.fill")
                    .font(DS.Typography.bodyMedium)
                    .foregroundStyle(DS.Color.success)
                    .transition(.scale.combined(with: .opacity))
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Space.x2)
    }

    // MARK: - Ready Page

    private var readyPage: some View {
        VStack(spacing: 0) {
            Spacer()

            // Celebration icon with scale bounce
            ZStack {
                // Expanding celebration ring
                Circle()
                    .stroke(DS.Color.accent.opacity(0.15), lineWidth: 1.5)
                    .frame(width: 160, height: 160)
                    .scaleEffect(iconFloating ? 1.1 : 0.9)
                    .opacity(iconFloating ? 0.3 : 0.8)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: iconFloating
                    )

                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 120, height: 120)

                Image(systemName: "sparkles")
                    .font(DS.Typography.alongSans(size: 48, weight: "Regular"))
                    .foregroundStyle(DS.Color.accent)
                    .symbolEffect(.bounce, options: .repeating.speed(0.3))
            }
            .transition(.asymmetric(
                insertion: .scale(scale: 0.5).combined(with: .opacity),
                removal: .scale(scale: 1.2).combined(with: .opacity)
            ))

            Spacer().frame(height: DS.Space.x3)

            Text("Hazırsınız!")
                .font(DS.Typography.displayTitle)
                .foregroundStyle(DS.Color.textPrimary)

            Spacer().frame(height: DS.Space.md)

            Text("Sükûn ile huzurlu bir\nibadet deneyimine başlayın.")
                .font(DS.Typography.alongSans(size: 16, weight: "Regular"))
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, DS.Space.x2)
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        DSButton(buttonTitle) {
            handleAction()
        }
    }

    private var buttonTitle: String {
        switch currentPage {
        case 0: return "Başlayalım"
        case 1: return locationGranted ? "Devam" : "Konum İzni Ver"
        case 2: return notificationGranted ? "Devam" : "Bildirimleri Aç"
        case 3: return "Uygulamaya Gir"
        default: return "Devam"
        }
    }

    private func handleAction() {
        DS.Haptic.softTap()

        switch currentPage {
        case 0:
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { currentPage = 1 }

        case 1:
            if locationGranted {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { currentPage = 2 }
            } else {
                Task {
                    await container.locationService.requestPermission()
                    // Check actual system authorization — don't assume success
                    let status = CLLocationManager().authorizationStatus
                    locationGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { currentPage = 2 }
                }
            }

        case 2:
            if notificationGranted {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { currentPage = 3 }
            } else {
                Task {
                    let granted = (try? await container.notificationScheduler.requestAuthorization()) ?? false
                    notificationGranted = granted
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { currentPage = 3 }
                }
            }

        case 3:
            DS.Haptic.success()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                hasCompletedOnboarding = true
            }

        default:
            break
        }
    }
}
