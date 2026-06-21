import SwiftUI
import SwiftData

/// Screen 2 — Add Vehicle (onboarding + Garage "add").
/// Requires year + make + model; trim optional. On save → create vehicle, set
/// active, advance to Sync.
struct AddVehicleView: View {
    @Environment(\.modelContext) private var context

    /// Called with the newly created vehicle once saved.
    var onSaved: (Vehicle) -> Void
    /// Optional back affordance (used when presented from Garage). Nil on first run.
    var onBack: (() -> Void)? = nil

    @State private var year = ""
    @State private var make = ""
    @State private var model = ""
    @State private var trim = ""

    private var canSave: Bool {
        !year.trimmed.isEmpty && !make.trimmed.isEmpty && !model.trimmed.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let onBack {
                        BackButton(action: onBack).padding(.bottom, GBSpace.sm)
                    }

                    Text("Vehicle setup").gbText(.label, color: GBColor.cream(0.48))
                    Text("Add your vehicle")
                        .gbText(.pageTitle)
                        .padding(.top, GBSpace.xs)
                    Text("We'll cache its manual and common fixes so the assistant works offline.")
                        .gbText(.body, color: GBColor.cream(0.6))
                        .padding(.top, GBSpace.xs)

                    VStack(spacing: GBSpace.md) {
                        HStack(alignment: .top, spacing: GBSpace.sm) {
                            GBTextField(label: "Year", text: $year,
                                        keyboard: .numberPad, autocapitalization: .never)
                                .frame(width: 110)
                            GBTextField(label: "Make", text: $make)
                        }
                        GBTextField(label: "Model", text: $model)
                        GBTextField(label: "Trim / Engine", optional: true, text: $trim)
                    }
                    .padding(.top, GBSpace.lg + 2)

                    privacyNote.padding(.top, GBSpace.lg - 4)
                }
                .padding(.horizontal, GBSpace.lg + 2)
                .padding(.top, GBSpace.md)
                .padding(.bottom, GBSpace.xl)
            }

            footer
        }
        .background(GBColor.bgPrimary.ignoresSafeArea())
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: GBSpace.xs + 2) {
            Image(systemName: "info.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(GBColor.statusLime)
                .padding(.top, 1)
            Text("Vehicle and location data stay on your phone. Manual data is fetched once from public sources — disclosed here, never shared.")
                .gbText(.bodySmall, color: GBColor.cream(0.65))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(GBColor.lightEmerald.opacity(0.06),
                    in: RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GBRadius.input, style: .continuous)
                .strokeBorder(GBColor.lightEmerald.opacity(0.14), lineWidth: 1)
        )
    }

    private var footer: some View {
        VStack(spacing: 0) {
            Divider().overlay(GBColor.lightEmerald.opacity(0.1))
            PrimaryButton(title: "Save & cache offline", action: save)
                .opacity(canSave ? 1 : 0.5)
                .disabled(!canSave)
                .padding(.horizontal, GBSpace.lg + 2)
                .padding(.top, GBSpace.sm + 2)
                .padding(.bottom, GBSpace.xs)
        }
        .background(GBColor.bgPrimary)
    }

    private func save() {
        guard canSave else { return }
        let vehicle = VehicleStore.add(
            year: year.trimmed, make: make.trimmed,
            model: model.trimmed, trim: trim.trimmed, in: context)
        onSaved(vehicle)
    }
}

/// Small circular back chevron used on pushed/onboarding screens.
struct BackButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(GBColor.textPrimary)
                .frame(width: 34, height: 34)
                .background(GBColor.cream(0.06), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(GBColor.cream(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel("Back")
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
