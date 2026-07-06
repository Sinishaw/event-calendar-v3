//
//  DateWidget.swift
//  DateWidget
//
//  Ethiopian date (top) + Gregorian date (below). Displays the strings the
//  Flutter app writes via home_widget into the shared App Group; no date
//  conversion happens here. @main lives in DateWidgetBundle.swift.
//

import SwiftUI
import WidgetKit

// App Group shared with the Flutter app. Must match Runner.entitlements,
// DateWidget.entitlements, and HomeWidget.setAppGroupId(...) in Dart.
private let appGroupId = "group.com.example.eventCalendarV2"

// Keys written by HomeWidgetService (Dart) via home_widget.
private let keyDateWindow = "date_window"
private let keyDateEt = "date_et"
private let keyDateGc = "date_gc"

/// One precomputed day from the rolling window the Dart side stores.
private struct WindowDay: Decodable {
    let d: String   // yyyy-MM-dd (local)
    let et: String
    let gc: String
}

struct DateEntry: TimelineEntry {
    let date: Date
    let etText: String
    let gcText: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DateEntry {
        DateEntry(date: Date(), etText: "—", gcText: "—")
    }

    func getSnapshot(in context: Context, completion: @escaping (DateEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DateEntry>) -> Void) {
        let entries = windowEntries()
        let timeline = Timeline(
            entries: entries.isEmpty ? [currentEntry()] : entries,
            policy: .atEnd
        )
        completion(timeline)
    }

    // MARK: - Data

    private func defaults() -> UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    /// Today's strings for snapshot/fallback (single date_et/date_gc keys).
    private func currentEntry() -> DateEntry {
        let d = defaults()
        return DateEntry(
            date: Date(),
            etText: d?.string(forKey: keyDateEt) ?? "—",
            gcText: d?.string(forKey: keyDateGc) ?? "—"
        )
    }

    /// Build one entry per local midnight from the precomputed window so the
    /// date rolls over without the app running. The first entry starts today.
    private func windowEntries() -> [DateEntry] {
        guard let json = defaults()?.string(forKey: keyDateWindow),
              let data = json.data(using: .utf8),
              let days = try? JSONDecoder().decode([WindowDay].self, from: data)
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
            // Make the first day effective immediately; later days at midnight.
            let effective = index == 0 ? startOfToday : midnight
            entries.append(DateEntry(date: effective, etText: day.et, gcText: day.gc))
        }
        return entries
    }
}

struct DateWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            // Lock-screen: system renders monochrome/tinted; keep it plain.
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.etText).font(.headline).lineLimit(1).minimumScaleFactor(0.6)
                Text(entry.gcText).font(.caption2).lineLimit(1).minimumScaleFactor(0.6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        default:
            // Home-screen small/medium. iOS gives the widget a system-managed
            // background (transparency isn't allowed), so use adaptive label
            // colors: dark on the light card, light in dark mode.
            VStack(spacing: family == .systemMedium ? 6 : 4) {
                Text(entry.etText)
                    .font(.system(size: family == .systemMedium ? 22 : 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(entry.gcText)
                    .font(.system(size: family == .systemMedium ? 14 : 11, weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .multilineTextAlignment(.center)
            .padding(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct DateWidget: Widget {
    let kind: String = "DateWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DateWidgetEntryView(entry: entry)
                .widgetBackground()
        }
        .configurationDisplayName("Ethiopian Date")
        .description("Today's Ethiopian date with the Gregorian date below.")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        if #available(iOSApplicationExtension 16.0, *) {
            return [.systemSmall, .systemMedium, .accessoryRectangular]
        } else {
            return [.systemSmall, .systemMedium]
        }
    }
}

// MARK: - Transparency helper

extension View {
    /// iOS 17+ requires Home Screen widgets to declare a background, and does
    /// not allow true transparency there — so use the adaptive system
    /// background (light card in light mode, dark in dark mode).
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(.background, for: .widget)
        } else {
            self
        }
    }
}
