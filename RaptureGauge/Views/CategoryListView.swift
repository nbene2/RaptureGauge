import SwiftUI

struct CategoryListView: View {
    let calculator: RaptureCalculator
    @State private var categoryScores: [Category: Float] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryCard(
                        category: category,
                        score: categoryScores[category] ?? 0,
                        conditions: calculator.getActiveConditionsForCategory(category)
                    )
                }
            }
            .padding()
        }
        .onAppear {
            categoryScores = calculator.getCategoryScores()
        }
    }
}

struct CategoryCard: View {
    let category: Category
    let score: Float
    let conditions: [RaptureCondition]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Circle()
                    .fill(Color(category.color))
                    .frame(width: 12, height: 12)

                Text(category.rawValue)
                    .font(.headline)

                Spacer()

                Text("\(Int(score))%")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(scoreColor)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(Color(category.color))
                        .frame(width: geometry.size.width * CGFloat(score / 100), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)

            // Weight indicator
            HStack {
                Text("Weight: \(Int(category.weight))/10")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(conditions.count) active conditions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Expanded conditions list
            if isExpanded {
                Divider()

                if conditions.isEmpty {
                    Text("No active conditions in this category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                        .padding(.vertical, 8)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(conditions) { condition in
                            ConditionDetailRow(condition: condition)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
    }

    var scoreColor: Color {
        if score > 75 { return .red }
        if score > 50 { return .orange }
        if score > 25 { return .yellow }
        return .green
    }
}

struct ConditionDetailRow: View {
    let condition: RaptureCondition

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: statusIcon)
                    .font(.system(size: 12))
                    .foregroundColor(statusColor)

                Text(condition.scriptureReference)
                    .font(.system(size: 13, weight: .medium))

                Spacer()

                if let date = condition.fulfillmentDate {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(condition.scriptureQuote)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text(condition.dataSource)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(1)

                Spacer()

                Text("Confidence: \(Int(condition.confidenceScore * 100))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    var statusIcon: String {
        switch condition.currentStatus {
        case .fulfilled:
            return "checkmark.circle.fill"
        case .active:
            return "circle.fill"
        case .emerging:
            return "circle.lefthalf.filled"
        case .notMet:
            return "circle"
        case .expired:
            return "clock.badge.xmark"
        }
    }

    var statusColor: Color {
        switch condition.currentStatus {
        case .fulfilled:
            return .green
        case .active:
            return .orange
        case .emerging:
            return .yellow
        case .notMet:
            return .gray
        case .expired:
            return .gray.opacity(0.5)
        }
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}