<div align="right">
  <a href="./README.md">Angielski</a> | <strong>Polski</strong>
</div>


# Analiza Retencji i Trendu Przychodów B2B

> **Uwaga dotycząca danych:** Wszelkie dane klientów, wolumeny zamówień oraz wartości finansowe wykorzystane w tym projekcie mają charakter wyłącznie syntetyczny i zostały wygenerowane na potrzeby projektu.



## Kontekst biznesowy
W sprzedaży B2B kluczowe znaczenie ma szybkie wychwycenie momentu, w którym strategiczny klient zaczyna kupować mniej. Raport rozwiązuje ten problem bezpośrednio na poziomie bazy danych ERP: automatycznie liczy dynamikę sprzedaży kwartał do kwartału (QoQ) i kategoryzuje kondycję klienta, umożliwiając zespołowi sprzedaży podjęcie wczesnych działań retencyjnych.



## Zastosowane technologie i wzorce analityczne
* **Tymczasowe tabele logiczne** (CTE): Podział zapytania na dwa czytelne etapy - najpierw podsumowanie kwartalnych liczb, a dopiero potem ocena trendu.
* **Grupowanie po kwartałach** (`DATE_TRUNC`): Ujednolicenie dokładnych dat zamówień do pełnych kwartałów, co umożliwia rzetelne porównanie okres do okresu.
* **Analiza danych historycznych** (`LAG`): Pobieranie sprzedaży z wcześniejszego kwartału dla każdego klienta osobno, bez konieczności wolnego dublowania tabel.
* **Automatyczne flagowanie wyników** (`CASE WHEN`): Proste reguły biznesowe przypisujące klientowi czytelną etykietę (`Nowy okres`, `Spadek`, `Wzrost lub stabilnie`) w zależności od wyniku.



## Podgląd wyników zapytania

| Nazwa firmy | Kwartał zamówienia | Liczba zamówień | Przychód kwartalny | Przychód z poprzedniego kwartału | Trend przychodów |
| :--- | :---: | :---: | :---: | :---: | :--- |
| Apex Solutions Ltd | 2026-01-01 | 2 | 120 000,00 zł | *NULL* | `Nowy okres` |
| Apex Solutions Ltd | 2026-04-01 | 1 | 50 000,00 zł | 120 000,00 zł | `Spadek` |
| Vanguard Retail Inc | 2026-01-01 | 1 | 25 000,00 zł | *NULL* | `Nowy okres` |
| Vanguard Retail Inc | 2026-04-01 | 1 | 70 000,00 zł | 25 000,00 zł | `Wzrost lub stabilnie` |



## Wnioski i rekomendacje biznesowe
1. **Identyfikacja zagrożonego klienta:** Klient *Apex Solutions Ltd* odnotował spadek przychodów o 58,3% kwartał do kwartału w Q2. Raport generuje wczesny alert dla Dyrektora Sprzedaży w celu podjęcia natychmiastowych działań retencyjnych.
2. **Warstwa zasilająca Business Intelligence:** Zapytanie może bezpośrednio pełnić rolę widoku bazodanowego dla narzędzi BI (Power BI, Tableau), eliminując konieczność pisania złożonych miar kalkulacyjnych po stronie raportu.
