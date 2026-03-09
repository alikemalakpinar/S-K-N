import SwiftUI
import CoreLocation

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    let container: DependencyContainer

    @State private var currentPage = 0
    @State private var locationGranted = false
    @State private var notificationGranted = false
    @State private var selectedMethod = "Turkey"

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
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                // Bottom button
                bottomButton
                    .padding(.horizontal, DS.Space.lg)
                    .padding(.bottom, DS.Space.x3)
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
                // Outer ring
                Circle()
                    .stroke(DS.Color.accent.opacity(0.15), lineWidth: 1)
                    .frame(width: 180, height: 180)

                Circle()
                    .stroke(DS.Color.accent.opacity(0.1), lineWidth: 1)
                    .frame(width: 220, height: 220)

                // Moon crescent
                ZStack {
                    Circle()
                        .fill(DS.Color.accent.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(DS.Color.accent)
                }
            }

            Spacer().frame(height: DS.Space.x4)

            // App name
            Text("Sükûn")
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(DS.Color.textPrimary)
                .tracking(-1)

            Spacer().frame(height: DS.Space.md)

            // Tagline
            Text("Huzurlu bir ibadet deneyimi")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(DS.Color.textSecondary)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Location Page

    private var locationPage: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 120, height: 120)
                Image(systemName: "location.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(DS.Color.accent)
            }

            Spacer().frame(height: DS.Space.x3)

            Text("Konum Erişimi")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Color.textPrimary)

            Spacer().frame(height: DS.Space.md)

            Text("Namaz vakitlerini ve kıble yönünü\ndoğru hesaplayabilmemiz için\nkonumunuza ihtiyacımız var.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: DS.Space.x2)

            if locationGranted {
                Label("Konum izni verildi", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.green)
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

            // Icon
            ZStack {
                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 120, height: 120)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(DS.Color.accent)
            }

            Spacer().frame(height: DS.Space.x3)

            Text("Bildirimler")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Color.textPrimary)

            Spacer().frame(height: DS.Space.md)

            Text("Namaz vakti geldiğinde\nsizi haberdar edelim.")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(DS.Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer().frame(height: DS.Space.x2)

            if notificationGranted {
                Label("Bildirim izni verildi", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.green)
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

            // Celebration icon
            ZStack {
                Circle()
                    .fill(DS.Color.accentSoft)
                    .frame(width: 120, height: 120)
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(DS.Color.accent)
            }

            Spacer().frame(height: DS.Space.x3)

            Text("Hazırsınız!")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(DS.Color.textPrimary)

            Spacer().frame(height: DS.Space.md)

            Text("Sükûn ile huzurlu bir\nibadet deneyimine başlayın.")
                .font(.system(size: 16, weight: .regular))
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
        Button {
            handleAction()
        } label: {
            Text(buttonTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DS.Color.accent)
                        .shadow(color: DS.Color.accent.opacity(0.3), radius: 12, y: 4)
                )
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
        switch currentPage {
        case 0:
            withAnimation { currentPage = 1 }

        case 1:
            if locationGranted {
                withAnimation { currentPage = 2 }
            } else {
                Task {
                    await container.locationService.requestPermission()
                    // Check actual system authorization — don't assume success
                    let status = CLLocationManager().authorizationStatus
                    locationGranted = (status == .authorizedWhenInUse || status == .authorizedAlways)
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation { currentPage = 2 }
                }
            }

        case 2:
            if notificationGranted {
                withAnimation { currentPage = 3 }
            } else {
                Task {
                    let granted = (try? await container.notificationScheduler.requestAuthorization()) ?? false
                    notificationGranted = granted
                    try? await Task.sleep(for: .milliseconds(500))
                    withAnimation { currentPage = 3 }
                }
            }

        case 3:
            withAnimation(.easeInOut(duration: 0.5)) {
                hasCompletedOnboarding = true
            }

        default:
            break
        }
    }
}
