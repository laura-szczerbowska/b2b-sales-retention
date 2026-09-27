# Analiza Retencji i Trendu Przychodów B2B (Studium przypadku SQL w systemie ERP)

> **Uwaga dotycząca danych:** Wszelkie dane klientów, wolumeny zamówień oraz wartości finansowe wykorzystane w tym projekcie mają charakter wyłącznie syntetyczny i zostały wygenerowane na potrzeby projektu analityczneego.

---

## Kontekst biznesowy
W modelach biznesowych B2B wczesne wykrywanie sygnałów spadku przychodów generowanych przez kluczowych klientów jest kluczowe dla skutecznego zapobiegania ich odejściu. Projekt dostarcza zautomatyzowany model raportowy SQL przygotowany pod bazy danych klasy ERP, który analizuje dynamikę sprzedaży kwartał do kwartału (QoQ) oraz kategoryzuje kondycję partnerów handlowych.

---

## 🛠️ Zastosowane technologie i wzorce analityczne
* **Wspólne Wyrażenia Tablicowe** (CTE): Logiczne odseparowanie warstwy agregacji danych transakcyjnych od docelowej kategoryzacji biznesowej.
* **Agregacja czasowa** (`DATE_TRUNC`): Spłaszczenie dokładnych znaczników czasu zamówień do spójnych okresów kwartalnych.
* **Funkcje okna** (`LAG`): Pobieranie przychodu z poprzedniego kwartału w ramach partycji klienta bez konieczności stosowania kosztownych samozłączeń (self-join).
* **Logika warunkowa** (`CASE WHEN`): Automatyczna klasyfikacja kondycji klienta na podstawie dynamiki sprzedaży (`Nowy okres`, `Spadek`, `Wzrost lub stabilnie`).

---

## 📈 Podgląd wyników zapytania

| Nazwa firmy | Kwartał zamówienia | Liczba zamówień | Przychód kwartalny | Przychód z poprzedniego kwartału | Trend przychodów |
| :--- | :---: | :---: | :---: | :---: | :--- |
| Apex Solutions Ltd | 2026-01-01 | 2 | 120 000,00 zł | *NULL* | `Nowy okres` |
| Apex Solutions Ltd | 2026-04-01 | 1 | 50 000,00 zł | 120 000,00 zł | `Spadek` |
| Vanguard Retail Inc | 2026-01-01 | 1 | 25 000,00 zł | *NULL* | `Nowy okres` |
| Vanguard Retail Inc | 2026-04-01 | 1 | 70 000,00 zł | 25 000,00 zł | `Wzrost lub stabilnie` |

---

## 💡 Wnioski i rekomendacje biznesowe
1. **Identyfikacja zagrożonego klienta:** Klient *Apex Solutions Ltd* odnotował spadek przychodów o 58,3% kwartał do kwartału w Q2. Raport generuje wczesny alert dla Dyrektora Sprzedaży / Key Account Managera w celu podjęcia natychmiastowych działań retencyjnych.
2. **Warstwa zasilająca Business Intelligence:** Zapytanie może bezpośrednio pełnić rolę widoku bazodanowego dla narzędzi BI (Power BI, Tableau), eliminując konieczność pisania złożonych miar kalkulacyjnych po stronie raportu.
