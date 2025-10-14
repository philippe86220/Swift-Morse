# 📘 Présenter une vue en SwiftUI

## Sommaire
1. [Introduction](#1-introduction)
2. [Spacer](#2-spacer)
3. [Polices système](#3-polices-système)
4. [Tailles des polices système](#4-tailles-des-polices-système-swiftui)
5. [Frame](#5-frame)
6. [Espacements et marges](#6-espacements-et-marges)
7. [Alignements fins](#7-alignements-fins)
8. [Divider Group Section](#8-divider-group-section)
9. [GeometryReader](#9-geometryreader)
10. [Safe area et fond plein écran](#10-safe-area--fond-plein-écran)
11. [Exemples complets](#11-exemples-complets)
12. [Cheat-sheet](#12-cheat-sheet)

## 1) Introduction
Une vue SwiftUI est déclarative : on compose l’interface avec des *stacks*, des espacements, des cadres (`frame`), des polices (`font`) et des styles. Chaque vue est une structure conforme à `View`, contenant une propriété :
```swift
var body: some View {
    VStack {
        Text("Bonjour SwiftUI")
        Button("Appuyer") { print("Tap") }
    }
}
```

## 2) Spacer
`Spacer()` crée de l’espace flexible dans un `VStack` ou `HStack`.
```swift
VStack {
    Text("Titre").font(.title)
    Spacer()
    Button("Continuer") { }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.blue)
        .foregroundStyle(.white)
        .cornerRadius(12)
}
.padding()
```
```swift
HStack {
    Text("Gauche")
    Spacer()
    Text("Droite")
}
```
```swift
HStack {
    Spacer(); Text("A"); Spacer()
    Text("B"); Spacer()
    Text("C"); Spacer()
}
```

## 3) Polices système
### A. Styles adaptatifs
```swift
Text("Titre").font(.largeTitle)
Text("Sous-titre").font(.title2)
Text("Texte").font(.body)
Text("Annotation").font(.caption)
```
Ces styles s’adaptent à la taille de texte définie par l’utilisateur.

### B. Polices précises
```swift
Text("Texte précis")
    .font(.system(size: 18, weight: .semibold, design: .rounded))
```

### C. Variantes
```swift
Text("Chiffres alignés").monospacedDigit()
Text("Code").font(.system(.body, design: .monospaced))
Text("Gras").bold()
Text("Italique").italic()
Text("Souligné").underline()
```

## 4) Tailles des polices système SwiftUI
| Style | Taille approx. (pt) | Usage recommandé |
|--------|---------------------|------------------|
| `.caption2` | 11 | Notes, légendes secondaires |
| `.caption` | 12 | Légendes, annotations |
| `.footnote` | 13 | Petits textes informatifs |
| `.subheadline` | 15 | Sous-titres discrets |
| `.callout` | 16 | Texte explicatif ou complémentaire |
| `.body` | 17 | Texte standard, lisible par défaut |
| `.headline` | 17 (gras) | Titres de section |
| `.title3` | 20 | Sous-titres importants |
| `.title2` | 22 | Titres intermédiaires |
| `.title` | 28 | Titre d’écran |
| `.largeTitle` | 34 | Titre principal d’application |

## 5) Frame
Définit la taille ou l’alignement d’une vue.
```swift
Text("Bouton plein écran")
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding()
    .background(.gray.opacity(0.1))
    .cornerRadius(8)
```
```swift
Color.blue
    .frame(width: 120, height: 80)
    .cornerRadius(12)
```
```swift
Text("Titre")
    .frame(minHeight: 44)
```

## 6) Espacements et marges
- `spacing` : espace **entre** les éléments d’un stack
- `padding` : marge **autour** d’un élément
```swift
VStack(spacing: 12) {
    Text("Titre").font(.title)
    Text("Texte descriptif")
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
}
.padding(.top, 24)
.padding(.horizontal, 16)
```

## 7) Alignements fins
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Nom")
    Text("Adresse")
}
```
```swift
HStack(alignment: .firstTextBaseline) {
    Text("Grand").font(.title)
    Text("petit").font(.caption)
}
```

## 8) Divider, Group, Section
```swift
VStack(spacing: 16) {
    Text("Informations").font(.headline)
    Group {
        Text("Nom : Alice")
        Text("Ville : Paris")
    }
    Divider()
    Text("Autres détails").font(.subheadline)
}
.padding()
```
```swift
List {
    Section("Profil") {
        Text("Nom : Alice")
        Text("Âge : 42")
    }
    Section("Préférences") {
        Text("Mode sombre : Oui")
    }
}
```

## 9) GeometryReader
```swift
GeometryReader { geo in
    VStack {
        Text("Largeur: \(Int(geo.size.width))")
        RoundedRectangle(cornerRadius: 12)
            .frame(width: geo.size.width * 0.8, height: 12)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .padding()
}
```

## 10) Safe area & fond plein écran
```swift
ZStack {
    Color(.systemGroupedBackground).ignoresSafeArea()
    VStack {
        Text("Contenu")
        Spacer()
    }
}
```
```swift
VStack {
    Text("Contenu")
}
.safeAreaInset(edge: .bottom) {
    Button("Action bas") { }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue)
        .foregroundStyle(.white)
}
```

## 11) Exemples complets
### A. Écran standard
```swift
struct EcranStandard: View {
    var body: some View {
        
        ZStack {
#if os(iOS)
            Color(UIColor.systemBackground).ignoresSafeArea()
#elseif os(macOS)
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
#endif
            
            //Color(UIColor.systemBackground).ignoresSafeArea()
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                    Text("Morse Player")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    Spacer()
                }
                .padding(.horizontal)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message").font(.headline)
                    Text("Appuyez pour jouer le code Morse du texte ci-dessous.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("SOS SOS SOS")
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                Spacer()
                Button {
                    // action lecture
                } label: {
                    Text("▶︎ Lire le Morse")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
    }
}

```
### B. Barre de progression
```swift
struct ProgressBar: View {
    
    var progress: CGFloat = 0.0 // valeur par défaut
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(.gray.opacity(0.2))
                Capsule()
                    .fill(.green)
                    .frame(width: max(0, min(progress, 1)) * geo.size.width)
            }
        }
        .frame(height: 8)
        .clipShape(Capsule())
    }
}
```
### C. Carte d’info
```swift
struct InfoCard: View {
    let title: String = "Title"
    let subtitle: String = "Subtitle"
    let systemIcon: String = "arrow.2.circlepath.circle"
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemIcon)
                .font(.system(size: 22, weight: .bold))
                .frame(width: 36, height: 36)
                .background(.blue.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(.background)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
```

## 12) Cheat-sheet
| Objectif | Outil |
|-----------|-------|
| Mettre à la ligne / colonne | `HStack` / `VStack` (+ `spacing`) |
| Superposer | `ZStack` |
| Créer de l’espace flexible | `Spacer()` |
| Marges | `.padding([.top/.horizontal], value)` |
| Remplir l’espace | `.frame(maxWidth: .infinity, maxHeight: .infinity)` |
| Aligner le contenu | `.frame(..., alignment: .leading)` |
| Polices accessibles | `.font(.title2 / .body / .caption)` |
| Polices paramétrées | `.font(.system(size:weight:design:))` |
| Chiffres alignés | `.monospacedDigit()` |
| Fonds & coins arrondis | `.background(...)` + `.cornerRadius(...)` |
| Ligne séparatrice | `Divider()` |
| Ignorer la safe area | `.ignoresSafeArea()` |
| Insérer un élément dans la safe area | `.safeAreaInset(edge:)` |
| Mise en page dépendante de la taille | `GeometryReader` |

> 🟢 **Conseil final :** Structure d’abord ta hiérarchie avec `VStack`, `HStack`, `ZStack` + `Spacer()`. Ajoute ensuite `padding`, `frame`, `font` et `background` pour ajuster visuellement, sans surcharger le code.
