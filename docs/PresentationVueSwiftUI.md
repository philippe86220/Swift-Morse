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
11. [Exemples complets (annotés)](#11-exemples-complets-annotés)
12. [Cheat-sheet](#12-cheat-sheet)

> ℹ️ Cette version est **pédagogique** : chaque extrait est **commenté ligne par ligne** pour expliquer le *pourquoi* (pas seulement le *comment*).

## 1) Introduction
Une vue SwiftUI est déclarative : on compose l’interface avec des *stacks*, des espacements, des cadres (`frame`), des polices (`font`) et des styles. Chaque vue est une structure conforme à `View`, contenant une propriété :
```swift
var body: some View {
    VStack { // Empile verticalement
        Text("Bonjour SwiftUI") // Élément textuel
        Button("Appuyer") { print("Tap") } // Action au toucher
    } // VStack gère le flux vertical + l'alignement si besoin
} // body décrit *ce qu'on veut voir*
```

## 2) Spacer
`Spacer()` crée de l’espace flexible dans un `VStack` ou `HStack`.
```swift
VStack {
    Text("Titre").font(.title) // Titre visible en haut
    Spacer() // Occupe tout l'espace vertical disponible → pousse le bouton en bas
    Button("Continuer") { /* action */ }
        .padding() // Zone cliquable + lisibilité
        .frame(maxWidth: .infinity) // S'étire sur toute la largeur
        .background(.blue) // Fond bleu du bouton
        .foregroundStyle(.white) // Texte du bouton en blanc
        .cornerRadius(12) // Bouton arrondi
}
.padding() // Évite que le contenu colle aux bords de l'écran
```
```swift
HStack {
    Text("Gauche")
    Spacer() // Pousse le suivant à l'extrémité droite
    Text("Droite")
}
```
```swift
HStack {
    Spacer(); Text("A"); Spacer() // Espaces symétriques
    Text("B"); Spacer()
    Text("C"); Spacer()
}
```

## 3) Polices système
### A. Styles adaptatifs
```swift
Text("Titre").font(.largeTitle) // Titre principal (s'adapte accessibilité)
Text("Sous-titre").font(.title2) // Sous-titre
Text("Texte").font(.body) // Texte courant
Text("Annotation").font(.caption) // Légendes
```
Ces styles s’adaptent à la taille de texte définie par l’utilisateur (accessibilité).

### B. Polices précises
```swift
Text("Texte précis")
    .font(.system(size: 18, weight: .semibold, design: .rounded)) // Taille/poids/design figés
```

### C. Variantes utiles
```swift
Text("Chiffres alignés").monospacedDigit() // Alignement vertical parfait pour nombres
Text("Code").font(.system(.body, design: .monospaced)) // Police type code
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
    .frame(maxWidth: .infinity, alignment: .leading) // Occupe toute la largeur + aligné à gauche
    .padding() // Espace autour du texte
    .background(.gray.opacity(0.1)) // Fond léger
    .cornerRadius(8) // Coins arrondis
```
```swift
Color.blue
    .frame(width: 120, height: 80) // Taille fixe
    .cornerRadius(12)
```
```swift
Text("Titre")
    .frame(minHeight: 44) // Hauteur minimale (zone tactile confortable)
```

## 6) Espacements et marges
- `spacing` : espace **entre** les éléments d’un stack
- `padding` : marge **autour** d’un élément
```swift
VStack(spacing: 12) { // Espacement vertical uniforme
    Text("Titre").font(.title)
    Text("Texte descriptif")
        .font(.subheadline)
        .multilineTextAlignment(.center) // Casser les lignes proprement
        .padding(.horizontal) // Marges latérales pour la lisibilité
}
.padding(.top, 24) // Dégager le haut de l'écran
.padding(.horizontal, 16) // Cohérence des marges latérales
```

## 7) Alignements fins
```swift
VStack(alignment: .leading, spacing: 8) {
    Text("Nom")
    Text("Adresse")
} // Tous les textes alignés à gauche, espacés de 8 pts
```
```swift
HStack(alignment: .firstTextBaseline) { // Aligne la première ligne de texte
    Text("Grand").font(.title)
    Text("petit").font(.caption)
}
```

## 8) Divider, Group, Section, List
```swift
VStack(spacing: 16) {
    Text("Informations").font(.headline)
    Group { // Grouper sans impact visuel mais utile pour organiser
        Text("Nom : Alice")
        Text("Ville : Paris")
    }
    Divider() // Séparation visuelle
    Text("Autres détails").font(.subheadline)
}
.padding()
```
🧾 List { ... } en SwiftUI est une vue puissante pour composer rapidement des interfaces à lignes multiples :  
défilement natif, mise à jour automatique des données, séparateurs, sections, gestes de swipe, etc.

### A) Liste avec sections (statique)

```swift
List {
    Section("Profil") { // En-tête + séparation automatique
        Text("Nom : Alice")
        Text("Âge : 42")
    }
    Section("Préférences") {
        Text("Mode sombre : Oui")
    }
}
//.listStyle(.insetGrouped) // Style moderne sur iOS

```

### B) Liste d’éléments (données simples)

> id: \.self convient pour des String uniques.

```swift

struct VuePrenoms: View {
    // On peut aussi rendre ce tableau global, mais le mettre ici rend la vue autonome
    let items = [
        "Alice","David","Éric","Fabien","Guillaume","Henri","Isabelle","Julien",
        "Kévin","Léa","Marc","Nicolas","Olivia","Pierre","Quentin","Raoul",
        "Sophie","Théo","Ursule","Victor","William"
    ]

    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
        //.listStyle(.insetGrouped) // Style moderne sur iOS
    }
}

```
### C) Variante dynamique (suppression, insertion, rafraîchissement)

> Utilise @State si la liste doit changer (supprimer/ajouter).


```swift
struct VuePrenomsDynamique: View {
    @State private var items = [
        "Alice","David","Éric","Fabien","Guillaume","Henri","Isabelle","Julien",
        "Kévin","Léa","Marc","Nicolas","Olivia","Pierre","Quentin","Raoul",
        "Sophie","Théo","Ursule","Victor","William"
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Prénoms") {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                EditButton() // Active le mode édition (supprimer/réordonner)
                Button {
                    // Exemple d’insertion
                    items.insert("Nouveau", at: 0)
                } label: {
                    Image(systemName: "plus")
                }
            }
            .refreshable {
                // Pull to refresh (si données distantes)
                await Task.sleep(NSEC_PER_SEC / 2) // simulé
            }
             //.listStyle(.insetGrouped) // Style moderne sur iOS
        }
    }
}
```

## 9) GeometryReader
```swift
GeometryReader { geo in // Fournit la taille disponible (geo.size)
    VStack {
        Text("Largeur: \(Int(geo.size.width))") // Debug utile
        RoundedRectangle(cornerRadius: 12)
            .frame(width: geo.size.width * 0.8, height: 12) // 80% de la largeur
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Remplir + placer en haut
    .padding()
} // ⚠️ À utiliser avec parcimonie (peut casser certaines mises en page)
```

## 10) Safe area & fond plein écran
```swift
ZStack {
    #if os(iOS)
    Color(UIColor.systemBackground).ignoresSafeArea() // Fond adaptatif clair/sombre iOS
    #elseif os(macOS)
    Color(NSColor.windowBackgroundColor).ignoresSafeArea() // Équivalent macOS
    #endif
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
.safeAreaInset(edge: .bottom) { // Ajoute une barre/zone en bas, au-dessus du home indicator
    Button("Action bas") { /* action */ }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue)
        .foregroundStyle(.white)
}
```

## 11) Exemples complets (annotés)
### A. Écran standard
```swift
struct EcranStandard: View {
    var body: some View {
        ZStack { // Superpose fond + contenu
            #if os(iOS)
            Color(UIColor.systemBackground).ignoresSafeArea() // Fond adaptatif
            #elseif os(macOS)
            Color(NSColor.windowBackgroundColor).ignoresSafeArea()
            #endif
            VStack(spacing: 16) { // Colonne principale
                HStack { // En-tête
                    Image(systemName: "waveform.path.ecg") // Icône statique
                    Text("Morse Player")
                        .font(.system(size: 28, weight: .bold, design: .rounded)) // Titre fort et lisible
                    Spacer() // Pousse le titre à gauche et libère l'espace à droite
                }
                .padding(.horizontal) // Marges latérales sur l'entête
                VStack(alignment: .leading, spacing: 8) { // Zone de message
                    Text("Message").font(.headline) // Libellé
                    Text("Appuyez pour jouer le code Morse du texte ci-dessous.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary) // Moins saillant
                        .fixedSize(horizontal: false, vertical: true) // Évite la coupure horizontale
                    Text("SOS SOS SOS")
                        .font(.system(size: 20, weight: .semibold, design: .monospaced)) // Look terminal
                        .padding() // Aère le bloc
                        .frame(maxWidth: .infinity, alignment: .leading) // S'étire et reste aligné à gauche
                        .background(.gray.opacity(0.1)) // Carte légère
                        .cornerRadius(10) // Carte arrondie
                }
                .padding(.horizontal) // Marges latérales sur le bloc texte
                Spacer() // Pousse le bouton en bas d'écran
                Button { /* action lecture */ } label: {
                    Text("▶︎ Lire le Morse")
                        .font(.title3)
                        .frame(maxWidth: .infinity) // Bouton plein largeur
                        .padding(.vertical, 14) // Hauteur confortable
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal)
                .padding(.bottom) // Dégage du bord bas
            }
        }
    }
}
```

### B. Barre de progression
```swift
struct ProgressBar: View {
    var progress: CGFloat = 0.0 // Valeur 0...1; défaut = 0
    var body: some View {
        GeometryReader { geo in // On récupère la largeur disponible
            ZStack(alignment: .leading) {
                Capsule().fill(.gray.opacity(0.2)) // Rail
                Capsule()
                    .fill(.green) // Remplissage
                    .frame(width: max(0, min(progress, 1)) * geo.size.width) // Clamp 0...1
            }
        }
        .frame(height: 8) // Hauteur fixe de la barre
        .clipShape(Capsule()) // Extrémités arrondies propres
    }
}
```

### C. Carte d’info
```swift
struct InfoCard: View {
    let title: String = "Title" // Valeurs par défaut → utilisable sans paramètres
    let subtitle: String = "Subtitle"
    let systemIcon: String = "arrow.2.circlepath.circle"
    var body: some View {
        HStack(spacing: 12) { // Ligne principale
            Image(systemName: systemIcon)
                .font(.system(size: 22, weight: .bold))
                .frame(width: 36, height: 36)
                .background(.blue.opacity(0.15)) // Pastille douce
                .clipShape(RoundedRectangle(cornerRadius: 8)) // Carré arrondi
            VStack(alignment: .leading, spacing: 2) { // Bloc textes
                Text(title).font(.headline) // Titre carte
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary) // Moins saillant
            }
            Spacer() // Pousse l'ensemble à gauche
        }
        .padding() // Aère la carte
        .background(.background) // S'adapte au thème clair/sombre
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 1) // Liseré fin
        )
        .clipShape(RoundedRectangle(cornerRadius: 12)) // Carte arrondie
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

> 🟢 **Conseil final :** Structure d’abord avec `VStack`, `HStack`, `ZStack` + `Spacer()`. Ajoute ensuite `padding`, `frame`, `font` et `background` pour un rendu propre, accessible et cohérent.
