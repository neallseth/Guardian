import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        VStack {
            Form {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Alert after")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Minutes", value: $timerManager.preferredTimerLengthMinutes, format: .number)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.gray, lineWidth: 1))
                }
                .padding(.horizontal, 20)
            }
            .frame(width: 350, height: 200)
            .padding(.bottom, 10)
        }
        .padding(.vertical, 10)
    }
}
