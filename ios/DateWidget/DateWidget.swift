//
//  DateWidget.swift
//  DateWidget
//
//  Ethiopian date widget. All content is precomputed in Dart (HomeWidgetService)
//  and shared via the App Group; this only decodes and displays it. Per family:
//    • Small  – Ethiopian + Gregorian date
//    • Medium – date + today's holiday / next-holiday countdown / event count
//    • Large  – agenda: ET & GC dates (day bold) in the top corners, upcoming
//               events (color-coded) in the middle, "+" to add at the bottom
//    • accessoryRectangular – lock-screen two-line date
//  @main lives in DateWidgetBundle.swift.
//

import SwiftUI
import WidgetKit

private let appGroupId = "group.com.example.eventCalendarV2"
private let keyDateWindow = "date_window"
private let keyDateEt = "date_et"
private let keyDateGc = "date_gc"

// Deep-link scheme delivered to Dart via home_widget's widgetClicked.
private let widgetScheme = "eventcalendarwidget"

// MARK: - Model (matches the JSON HomeWidgetService writes)

struct AgendaItem: Decodable {
    let title: String
    let detail: String
    let colorHex: String
    let dateLabel: String
    let time: String
    let gcDate: String?   // yyyy-MM-dd of the event (for tap → open that day)
    let scrollMin: Int?   // minutes-of-day to scroll the day view to
}

struct DayData: Decodable {
    let d: String
    let et: String
    let gc: String
    // ET components (day rendered bold in the Large corner).
    let etWeekday: String?
    let etMonthName: String?
    let etDay: String?
    let etYear: String?
    // GC components.
    let gcWeekday: String?
    let gcMonthName: String?
    let gcDay: String?
    let gcYear: String?
    // Medium context.
    let holidayToday: String?
    let nextHolidayName: String?
    let nextHolidayInDays: Int?
    let eventCount: Int?
    let daysLabel: String?
    let noEventsLabel: String?
    // Large agenda.
    let agenda: [AgendaItem]?

    static let placeholder = DayData(
        d: "", et: "—", gc: "—", etWeekday: nil, etMonthName: nil, etDay: nil,
        etYear: nil, gcWeekday: nil, gcMonthName: nil, gcDay: nil, gcYear: nil,
        holidayToday: nil, nextHolidayName: nil, nextHolidayInDays: nil,
        eventCount: nil, daysLabel: nil, noEventsLabel: nil, agenda: nil)
}

struct DateEntry: TimelineEntry {
    let date: Date
    let day: DayData
}

// MARK: - Timeline

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DateEntry {
        DateEntry(date: Date(), day: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DateEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DateEntry>) -> Void) {
        let entries = windowEntries()
        completion(Timeline(entries: entries.isEmpty ? [currentEntry()] : entries, policy: .atEnd))
    }

    private func defaults() -> UserDefaults? { UserDefaults(suiteName: appGroupId) }

    private func currentEntry() -> DateEntry {
        let d = defaults()
        let day = DayData(
            d: "", et: d?.string(forKey: keyDateEt) ?? "—",
            gc: d?.string(forKey: keyDateGc) ?? "—", etWeekday: nil, etMonthName: nil,
            etDay: nil, etYear: nil, gcWeekday: nil, gcMonthName: nil, gcDay: nil,
            gcYear: nil, holidayToday: nil, nextHolidayName: nil, nextHolidayInDays: nil,
            eventCount: nil, daysLabel: nil, noEventsLabel: nil, agenda: nil)
        return DateEntry(date: Date(), day: day)
    }

    private func windowEntries() -> [DateEntry] {
        guard let json = defaults()?.string(forKey: keyDateWindow),
              let data = json.data(using: .utf8),
              let days = try? JSONDecoder().decode([DayData].self, from: data)
        else { return [] }

        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"

        let startOfToday = Calendar.current.startOfDay(for: Date())
        var entries: [DateEntry] = []
        for (index, day) in days.enumerated() {
            guard let parsed = formatter.date(from: day.d) else { continue }
            let midnight = Calendar.current.startOfDay(for: parsed)
            entries.append(DateEntry(date: index == 0 ? startOfToday : midnight, day: day))
        }
        return entries
    }
}

// MARK: - Views

struct DateWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content.widgetBackground()
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.day.et).font(.headline).lineLimit(1).minimumScaleFactor(0.6)
                Text(entry.day.gc).font(.caption2).lineLimit(1).minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

        case .systemMedium:
            MediumView(day: entry.day)

        case .systemLarge:
            LargeAgendaView(day: entry.day)

        default: // .systemSmall
            VStack(spacing: 4) {
                Text(entry.day.et)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2).minimumScaleFactor(0.5)
                Text(entry.day.gc)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .lineLimit(2).minimumScaleFactor(0.5)
            }
            .multilineTextAlignment(.center)
            .padding(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// Medium: date + today's context (localized; "N days" spelled out).
private struct MediumView: View {
    let day: DayData

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(day.et)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(1).minimumScaleFactor(0.6)
            Text(day.gc)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineLimit(1).minimumScaleFactor(0.6)

            Divider().padding(.vertical, 2)

            if let h = day.holidayToday, !h.isEmpty {
                Label(h, systemImage: "star.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.red)
                    .lineLimit(1).minimumScaleFactor(0.6)
            } else if let n = day.nextHolidayName, !n.isEmpty {
                Label("\(n) · \(day.nextHolidayInDays ?? 0) \(day.daysLabel ?? "")",
                      systemImage: "calendar")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1).minimumScaleFactor(0.6)
            }
            if let c = day.eventCount, c > 0 {
                Label("\(c)", systemImage: "bell.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(12)
    }
}

/// Large: agenda — ET/GC dates in the corners, upcoming events, "+" to add.
private struct LargeAgendaView: View {
    let day: DayData

    var body: some View {
        VStack(spacing: 6) {
            HStack(alignment: .top) {
                DateCorner(weekday: day.etWeekday, month: day.etMonthName,
                           dayNum: day.etDay, year: day.etYear, alignment: .leading)
                Spacer(minLength: 8)
                DateCorner(weekday: day.gcWeekday, month: day.gcMonthName,
                           dayNum: day.gcDay, year: day.gcYear, alignment: .trailing)
            }

            Divider()

            let items = day.agenda ?? []
            if items.isEmpty {
                Spacer()
                Text(day.noEventsLabel ?? "No events")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                // Content-sized rows packed at the top; a single event does not
                // stretch. Each row taps through to its own day + time.
                VStack(spacing: 6) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        Link(destination: URL(string:
                            "\(widgetScheme)://open/day?d=\(item.gcDate ?? day.d)&t=\(item.scrollMin ?? 0)")!) {
                            AgendaRow(item: item)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                Spacer(minLength: 0)
            }

            // Bottom strip → add-event form (defaults to today). Full-width hit
            // target so the tap reliably routes to "add", not the widgetURL.
            Link(destination: URL(string: "\(widgetScheme)://open/add")!) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.tint)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetURL(URL(string: "\(widgetScheme)://open/day?d=\(day.d)"))
    }
}

private struct DateCorner: View {
    let weekday: String?
    let month: String?
    let dayNum: String?
    let year: String?
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 1) {
            if let w = weekday, !w.isEmpty {
                Text(w).font(.system(size: 11)).foregroundStyle(.secondary)
            }
            (Text("\(month ?? "") ").font(.system(size: 14))
                + Text(dayNum ?? "").font(.system(size: 14, weight: .bold))
                + Text(", \(year ?? "")").font(.system(size: 14)))
                .foregroundStyle(.primary)
                .lineLimit(1).minimumScaleFactor(0.6)
        }
    }
}

private struct AgendaRow: View {
    let item: AgendaItem

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: item.colorHex))
                .frame(width: 4)
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    if !item.dateLabel.isEmpty {
                        Text(item.dateLabel)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color(hex: item.colorHex))
                    }
                    Text(item.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                if !item.detail.isEmpty {
                    Text(item.detail)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 4)
            if !item.time.isEmpty {
                Text(item.time)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 6)
        .background(Color(hex: item.colorHex).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .fixedSize(horizontal: false, vertical: true) // take only the needed height
    }
}

// MARK: - Widget

struct DateWidget: Widget {
    let kind: String = "DateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DateWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Ethiopian Date")
        .description("Ethiopian date, upcoming events, and holidays.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge]
        }
    }
}

// MARK: - Helpers

extension Color {
    /// 6-digit "RRGGBB" hex (as written by HomeWidgetService).
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r = Double((v & 0xFF0000) >> 16) / 255.0
        let g = Double((v & 0x00FF00) >> 8) / 255.0
        let b = Double(v & 0x0000FF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}

extension View {
    /// iOS 17+ requires Home Screen widgets to declare a background and does not
    /// allow true transparency there — use the adaptive system background.
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(.background, for: .widget)
        } else {
            self
        }
    }
}
