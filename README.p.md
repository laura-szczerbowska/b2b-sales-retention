<div align="right">
  <a href="./README.en.md">English</a> | <strong>Polski</strong>
</div>

# Analiza Retencji i Trendu Przychodów B2B (SQL & Power BI)

> **Uwaga dotycząca danych:** Wszystkie dane transakcyjne, nazwy kontrahentów oraz wartości finansowe wykorzystane w tym projekcie mają charakter syntetyczny i zostały wygenerowane wyłącznie na potrzeby demonstracyjne.


<br>


## Kontekst biznesowy i cel projektu

W relacjach handlowych B2B systematyczny spadek wartości zamówień rzadko następuje z dnia na dzień. Wczesne wykrycie ujemnej dynamiki pozwala zespołowi sprzedaży (Key Account Management) zareagować, zanim kontrahent całkowicie odejdzie do konkurencji (churn).

**Cel projektu:**
Zbudowanie potoku analitycznego łączącego bazę danych ERP z interaktywnym dashboardem operacyjno-zarządczym w Power BI. Rozwiązanie agreguje transakcje do poziomów kwartalnych, śledzi dynamikę przychodów kwartał do kwartału (QoQ) oraz segmentuje portfel klientów pod kątem ryzyka retencyjnego.


<br>


## Dashboard zarządczy Power BI (Executive Summary)

Raport umożliwia kadrze menedżerskiej natychmiastową identyfikację kontrahentów z grupy ryzyka (*At Risk Accounts*) oraz przekrojową ocenę wolumenu i przychodu w ujęciu kwartalnym:


<br>


<img width="1375" height="776" alt="dashboard" src="https://github.com/user-attachments/assets/5262e376-8f39-4f7f-b7f7-ba6c04d0d9f2" />


<br>



### Kluczowe komponenty raportu:
- **Karty metryk KPI:** Syntetyczny podgląd łącznej liczby zamówień (15) oraz zagregowanego przychodu (837,00 tys. zł).
- **KPI "At Risk Accounts":** Wskaźnik alarmowy prezentujący liczbę kontrahentów, u których odnotowano spadek przychodów w ostatnim analizowanym okresie (2 podmioty).
- **Wykres liniowy (Quarterly Revenue Trend by Key Account):** Prezentacja dynamicznych trajektorii przychodowych poszczególnych klientów w roku 2025 (Q1–Q4).
- **Wykres słupkowy (Total orders by Company):** Zestawienie łącznego wolumenu zrealizowanych zamówień.
- **Macierz statusowa (Formatowanie warunkowe):** Tabela szczegółowa z automatycznym wyróżnianiem statusu `Decline` w kolorze czerwonym.
- **Interaktywny slicer (Choose company name...):** Dynamiczne filtrowanie całego widoku do wybranego kontrahenta.


<br>


## Architektura rozwiązania i warstwa SQL

Zgodnie z zasadą *Database First*, złożone kalkulacje okresowe i logiczne flagowanie trendów zostały zrealizowane bezpośrednio w zapytaniu SQL, odciążając silnik Power BI i eliminując potrzebę tworzenia skomplikowanych miar DAX.

### Zastosowane techniki SQL:
1. **Common Table Expressions (CTE):** Dwuetapowa transformacja danych: najpierw agregacja kwartalna, następnie analiza szeregów czasowych.
2. **Normalizacja dat (`DATE_TRUNC`):** Ujednolicenie precyzyjnych sygnatur czasowych zamówień do pierwszego dnia kwartału.
3. **Funkcje okna (`LAG() OVER (...)`):** Odczytanie wartości przychodu z poprzedniego kwartału per klient bez konieczności kosztownych złączeń własnych (`SELF JOIN`).
4. **Logika warunkowa (`CASE WHEN`):** Klasyfikacja statusu kontraktu (`New Period`, `Decline`, `Growth or Stable`).


<br>


```sql
WITH quarterly_summary AS (
    SELECT
        c.customer_id,
        c.company_name,
-- Sprowadzenie daty zamówienia do pierwszego dnia kwartału
        DATE_TRUNC('quarter', o.order_date) AS order_quarter,
        SUM(o.net_amount) AS quarterly_revenue,
        COUNT(o.order_id) AS total_orders,
-- Pobranie przychodu z poprzedniego kwartału per klient (funkcja okna)
        LAG(SUM(o.net_amount), 1) OVER (
            PARTITION BY c.customer_id 
            ORDER BY DATE_TRUNC('quarter', o.order_date) ASC
        ) AS previous_quarter_revenue
		
    FROM customers c
    INNER JOIN orders o 
        ON c.customer_id = o.customer_id
-- Zawężenie do strategicznych kontrahentów i zrealizowanych transakcji
    WHERE c.segment ='Key Account'
      AND o.status = 'Completed'
    GROUP BY
        c.customer_id,
        c.company_name,
        DATE_TRUNC('quarter', o.order_date)
)
SELECT
    company_name,
    order_quarter,
    total_orders,
    quarterly_revenue,
    previous_quarter_revenue,
-- Klasyfikacja dynamiki sprzedaży
    CASE
        WHEN previous_quarter_revenue IS NULL THEN 'New Period'
        WHEN quarterly_revenue < previous_quarter_revenue THEN 'Decline'
        ELSE 'Growth or Stable'
    END AS revenue_trend
	
FROM quarterly_summary
ORDER BY 
    company_name ASC, 
    order_quarter ASC;

```


<br>


## Zestawienie danych wynikowych

Model przetwarza pełen rok obrotowy 2025 dla 4 kluczowych kontrahentów:

| Nazwa firmy | Kwartał zamówienia | Liczba zamówień | Przychód kwartalny | Poprzedni kwartał | Status trendu |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Apex Solutions Ltd** | 2025-01-01 | 2 | 120 000,00 zł | *NULL* | `New Period` |
| **Apex Solutions Ltd** | 2025-04-01 | 1 | 50 000,00 zł | 120 000,00 zł | `Decline`|
| **Apex Solutions Ltd** | 2025-07-01 | 1 | 30 000,00 zł | 50 000,00 zł | `Decline` |
| **Apex Solutions Ltd** | 2025-10-01 | 1 | 20 000,00 zł | 30 000,00 zł | `Decline` |
| **Vanguard Retail Inc** | 2025-01-01 | 1 | 25 000,00 zł | *NULL* | `New Period` |
| **Vanguard Retail Inc** | 2025-04-01 | 1 | 70 000,00 zł | 25 000,00 zł | `Growth or Stable` |
| **Vanguard Retail Inc** | 2025-07-01 | 1 | 85 000,00 zł | 70 000,00 zł | `Growth or Stable`|
| **Vanguard Retail Inc** | 2025-10-01 | 1 | 110 000,00 zł | 85 000,00 zł | `Growth or Stable`|
| **Nordic Logistics AS** | 2025-01-01 | 1 | 60 000,00 zł | *NULL* | `New Period`|
| **Nordic Logistics AS** | 2025-04-01 | 1 | 62 000,00 zł | 60 000,00 zł | `Growth or Stable` |
| **Nordic Logistics AS** | 2025-07-01 | 1 | 40 000,00 zł | 62 000,00 zł | `Decline` |
| **Nordic Logistics AS** | 2025-10-01 | 1 | 65 000,00 zł | 40 000,00 zł | `Growth or Stable` |
| **Syllable Tech Sp. z o.o.** | 2025-07-01 | 1 | 45 000,00 zł | *NULL* | `New Period` |
| **Syllable Tech Sp. z o.o.** | 2025-10-01 | 1 | 55 000,00 zł | 45 000,00 zł | `Growth or Stable` |


<br>


## Wnioski analityczne i rekomendacje biznesowe

1. **Pilny alert retencyjny (Apex Solutions Ltd):**
   - Klient generował w Q1 największy pojedynczy przychód (120 tys. zł).
   - W kolejnych kwartałach nastąpił stały spadek: 50 tys. $\to$ 30 tys. $\to$ 20 tys. zł (łącznie -83,3% w skali roku).
   - **Rekomendacja:** Zorganizowanie bezpośredniego spotkania na szczeblu dyrektorskim w celu weryfikacji przyczyn niezadowolenia (jakość obsługi, pricing, konkurencja).


<br>

	 
<img width="1372" height="775" alt="dashboard1" src="https://github.com/user-attachments/assets/8385a468-4515-4d45-913c-548f37a6f948" />


<br>



2. **Główny motor wzrostu (Vanguard Retail Inc):**
   - Skalowanie współpracy z poziomu 25 tys. zł w Q1 do 110 tys. zł w Q4 (+340% r/r).
   - **Rekomendacja:** Objęcie klienta dedykowanym programem partnerskim i zaoferowanie kontraktu długoterminowego (SLA).

3. **Sezonowość vs. stabilizacja (Nordic Logistics AS):**
   - Spadek w Q3 (do 40 tys. zł) miał charakter przejściowy; w Q4 nastąpiło odbicie do 65 tys. zł.
   - **Rekomendacja:** Wprowadzenie promocji kwartalnych łagodzących spadki popytu w okresie wakacyjnym.

4. **Ekspansja nowego kontrahenta (Syllable Tech Sp. z o.o.):**
   - Pozyskanie klienta w Q3 (45 tys. zł) i natychmiastowy wzrost w Q4 (55 tys. zł).
   - **Rekomendacja:** Przygotowanie dedykowanej oferty cross-sellingowej na nadchodzący rok obrotowy.


<br>


## Jak uruchomić i odtworzyć projekt

### Wymagania wstępne:
- Zainstalowanie programu **Power BI Desktop**.
- Opcjonalnie: silnik bazy danych (PostgreSQL).

---

Sklonowanie repozytorium na dysk lokalny:
```
git clone https://github.com/laura-szczerbowska/b2b-revenue-retention-analysis.git
cd b2b-revenue-retention-analysis
```

Uruchomienie dashboardu Power BI
```
Otwórz plik b2b_revenue_retention_dashboard.pbix bezpośrednio w programie Power BI Desktop.
Plik posiada osadzony model danych - raport jest od razu w pełni interaktywny (filtry, slicery, drill-down).
```

Weryfikacja zapytania SQL
```
Otwórz plik b2b_revenue_analysis.sql w edytorze kodu lub narzędziu bazodanowym.
Zapytanie zawiera pełną logikę agregacji, funkcję okna LAG() oraz kategoryzację statusów za pomocą CASE WHEN.
```


<br>


## Stos technologiczny
- **Baza danych / Język zapytań:** PostgreSQL (Window Functions, CTEs, Aggregations)
- **Business Intelligence & Wizualizacja:** Power BI Desktop (`b2b_revenue_retention_dashboard.pbix`)
- **Modelowanie i transformacja:** SQL View / Power Query ETL
- **Repozytorium & Wersjonowanie:** Git / GitHub
