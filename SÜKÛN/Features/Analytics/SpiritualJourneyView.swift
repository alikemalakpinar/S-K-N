import SwiftUI
import Charts

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SpiritualJourneyView — Ultra-detailed SwiftCharts Dashboard
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

public struct SpiritualJourneyView: View {
    @StateObject private var engine = AnalyticsEngine()
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: DS.Space.x2) {
                
                // Dashboard Header
                VStack(alignment: .leading, spacing: DS.Space.sm) {
                    Text("MANEVİ ANALİZ")
                        .font(DS.Typography.sectionHead)
                        .foregroundStyle(DS.Color.accent)
                        .tracking(3)
                    
                    Text("Son 30 Günün Yankısı")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(DS.Color.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Space.lg)
                .padding(.top, DS.Space.xl)
                
                // Top Insight Aggregation Cards
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DS.Space.lg) {
                        metricCard(title: "Haftalık Namaz", value: String(format: "%.1f", engine.averagePrayersPerWeek), icon: "hands.sparkles.fill")
                        metricCard(title: "Hatim Tahmini", value: "\(engine.quranCompletionForecastDays) Gün", icon: "book.fill")
                        metricCard(title: "Toplam Zikir", value: "\(engine.totalDhikrThisMonth)", icon: "seal.fill")
                    }
                    .padding(.horizontal, DS.Space.lg)
                }
                
                // Massive SwiftChart: Prayer Consistency
                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    Text("NAMAZ İSTİKRARI")
                        .font(DS.Typography.headline)
                        .foregroundStyle(DS.Color.textSecondary)
                        .padding(.horizontal, DS.Space.lg)
                    
                    Chart {
                        ForEach(engine.thirtyDayHistory) { record in
                            BarMark(
                                x: .value("Day", record.date, unit: .day),
                                y: .value("Prayers", record.prayersCompleted)
                            )
                            .foregroundStyle(DS.Color.accent.gradient)
                            .cornerRadius(4)
                        }
                        
                        // RuleMark for Average
                        RuleMark(
                            y: .value("Average", 5.0)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(DS.Color.warning.opacity(0.8))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Farz (5)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(DS.Color.warning)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading, values: [0, 1, 2, 3, 4, 5])
                    }
                    .frame(height: 250)
                    .padding(DS.Space.lg)
                    .dsGlass(.thin, cornerRadius: DS.Radius.lg)
                    .dsShadow(DS.Shadow.premiumCard)
                    .padding(.horizontal, DS.Space.lg)
                }
                
                // AI Generated Insights List
                VStack(alignment: .leading, spacing: DS.Space.lg) {
                    Text("SÜKÛN YZ ÇIKARIMLARI")
                        .font(DS.Typography.headline)
                        .foregroundStyle(DS.Color.textSecondary)
                        .padding(.horizontal, DS.Space.lg)
                    
                    ForEach(engine.topInsights, id: \.title) { insight in
                        HStack(alignment: .top, spacing: DS.Space.md) {
                            
                            // Trend Icon
                            ZStack {
                                Circle()
                                    .fill(insight.trend == .upward ? DS.Color.success.opacity(0.2) : (insight.trend == .downward ? DS.Color.warning.opacity(0.2) : DS.Color.accentSoft))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: insight.trend == .upward ? "arrow.up.right" : (insight.trend == .downward ? "arrow.down.right" : "minus"))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(insight.trend == .upward ? DS.Color.success : (insight.trend == .downward ? DS.Color.warning : DS.Color.accent))
                            }
                            
                            VStack(alignment: .leading, spacing: DS.Space.xs) {
                                Text(insight.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(DS.Color.textPrimary)
                                
                                Text(insight.description)
                                    .font(DS.Typography.bodyMedium)
                                    .foregroundStyle(DS.Color.textSecondary)
                                    .lineSpacing(4)
                            }
                        }
                        .padding(DS.Space.lg)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .dsGlass(.regular, cornerRadius: DS.Radius.md)
                        .dsShadow(DS.Shadow.card)
                        .padding(.horizontal, DS.Space.lg)
                    }
                }
                
                Spacer(minLength: DS.Space.x3)
            }
        }
        .background(
            LinearGradient(
                colors: [DS.Color.backgroundPrimary, DS.Color.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()
        )
    }
    
    // MARK: - Subcomponents
    
    private func metricCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: DS.Space.md) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Color.accent)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(DS.Color.textPrimary)
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DS.Color.textSecondary)
                    .tracking(0.5)
            }
        }
        .frame(width: 140, height: 110)
        .padding(DS.Space.lg)
        .dsGlass(.thin, cornerRadius: DS.Radius.lg)
        .dsShadow(DS.Shadow.premiumCard)
    }
}
