import Foundation

extension String {
    func friendlyDateES() -> String {
        let srcFmt = DateFormatter()
        srcFmt.locale = Locale(identifier: "es_MX")
        srcFmt.dateFormat = "dd/MM/yyyy HH:mm:ss"
        
        guard let date = srcFmt.date(from: self) else { return self }
        
        let cal = Calendar.current
        if cal.isDateInToday(date) {
            let time = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            return "Hoy a las \(time)"
        } else if cal.isDateInYesterday(date) {
            let time = DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
            return "Ayer a las \(time)"
        } else {
            let dstFmt = DateFormatter()
            dstFmt.locale = Locale(identifier: "es_MX")
            dstFmt.dateFormat = "dd MMM yyyy · HH:mm"
            return dstFmt.string(from: date)
        }
    }
}
