library(PogromcyDanych)
data(auta2012)

# 1. Rozważając tylko obserwacje z PLN jako walutą (nie zważając na 
# brutto/netto): jaka jest mediana ceny samochodów, które mają napęd elektryczny?

auta2012 %>%
  select(Cena.w.PLN, Rodzaj.paliwa) %>%
  filter(Rodzaj.paliwa == "naped elektryczny") %>%
  summarise(mediana_ceny = median(Cena.w.PLN))

# Odp:
# Mediana ceny samochod�w z nap�dem elektrycznym wynosi 19600 PLN


# 2. W podziale samochodów na marki oraz to, czy zostały wyprodukowane w 2001 
# roku i później lub nie, podaj kombinację, dla której mediana liczby koni
# mechanicznych (KM) jest największa.

auta2012 %>%
  group_by(Marka,Rok.produkcji >= 2001, Rok.produkcji < 2001) %>%
  summarise(mediana_KM = median(KM, na.rm = TRUE)) %>%
  arrange(-mediana_KM)

# Odp: Bugatti wyprodukowane po lub w 2001 roku maj� najwi�ksz� median� KM.


# 3. Spośród samochodów w kolorze szary-metallic, których cena w PLN znajduje się
# pomiędzy jej średnią a medianą (nie zważając na brutto/netto), wybierz te, 
# których kraj pochodzenia jest inny niż kraj aktualnej rejestracji i poodaj ich liczbę.

auta2012 %>%
  mutate(mediana_ceny = median(Cena.w.PLN),srednia_ceny = mean(Cena.w.PLN)) %>%
  filter(Kolor == "szary-metallic", 
         (Cena.w.PLN > mediana_ceny & Cena.w.PLN < srednia_ceny) |
         (Cena.w.PLN > srednia_ceny & Cena.w.PLN < mediana_ceny)) %>%
  mutate(pochodzenie_inne_niz_rejestracja = as.character(Kraj.aktualnej.rejestracji) != as.character(Kraj.pochodzenia)) %>% 
  filter(pochodzenie_inne_niz_rejestracja) %>%
  #select(Marka,Model,Kolor,Cena.w.PLN,mediana_ceny,srednia_ceny,Kraj.aktualnej.rejestracji,Kraj.pochodzenia) %>%
  summarise(n=n())


# Odp: Jest takich aut 1849. (przyj��em, �e median� i �redni� liczymy ze wszystkich aut, a nie tylko w kolorze szary-metallic)



# 4. Jaki jest rozstęp międzykwartylowy przebiegu (w kilometrach) Passatów
# w wersji B6 i z benzyną jako rodzajem paliwa?

auta2012 %>%
  filter(Model == "Passat", Wersja == "B6", Rodzaj.paliwa == "benzyna") %>%
  summarize(q1 = quantile(Przebieg.w.km, probs = 0.25, na.rm = TRUE), 
            q3 = quantile(Przebieg.w.km, probs = 0.75, na.rm = TRUE)) %>%
  transmute(rozstep_miedzykwartylowy = q3-q1)
  
  
# Odp: Rozst�p mi�dzykwartylowy wynosi 75977.5 km.



# 5. Biorąc pod uwagę samochody, których cena jest podana w koronach czeskich,
# podaj średnią z ich ceny brutto.
# Uwaga: Jeśli cena jest podana netto, należy dokonać konwersji na brutto (podatek 2%).
auta2012 %>%
  filter(Waluta == "CZK") %>%
  mutate(cena_brutto = ifelse(Brutto.netto == "brutto", Cena, 1.02 * Cena)) %>%
  summarize(srednia_ceny_brutto = mean(cena_brutto))


# Odp: �rednia ceny brutto to 210678.3 CZK.



# 6. Których Chevroletów z przebiegiem większym niż 50 000 jest więcej: tych
# ze skrzynią manualną czy automatyczną? Dodatkowo, podaj model, który najczęściej
# pojawia się w obu przypadkach.


auta2012 %>%
  filter(Marka == "Chevrolet", Przebieg.w.km > 50000) %>%
  group_by(Skrzynia.biegow) %>%
  summarise(n=n())

auta2012 %>%
  filter(Marka == "Chevrolet", Przebieg.w.km > 50000) %>%
  group_by(Skrzynia.biegow) %>% 
  count(Model) %>%
  top_n(1)

# Odp: Wi�cej jest tych ze skrzyni� manualn� (336 > 112), najcz�stszy model
# z automatyczn� szkrzyni� to Corvette, a z manualn� to Lacetti.



# 7. Jak zmieniła się mediana pojemności skokowej samochodów marki Mercedes-Benz,
# jeśli weźmiemy pod uwagę te, które wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>%
  filter(Marka == "Mercedes-Benz") %>%
  mutate(Wiek = ifelse(Rok.produkcji <= 2003,"starszy","nowszy")) %>%
  group_by(Wiek) %>%
  summarize(mediana_pojemnosci = median(Pojemnosc.skokowa, na.rm = TRUE))
  


# Odp: Mediana pojemno�ci skokowej si� nie zmieni�a i wynosi 2200.



# 8. Jaki jest największy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodzących z Niemiec?

auta2012 %>%
  filter(Kraj.aktualnej.rejestracji == "Polska", Kraj.pochodzenia == "Niemcy") %>%
  top_n(3, Przebieg.w.km)

# Odp: Najwi�kszy przebieg to 999999999 km.



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodzących z Włoch?

auta2012 %>%
  filter(Marka == "Mitsubishi", Kraj.pochodzenia == "Wlochy") %>%
  group_by(Kolor) %>%
  summarise(n = n()) %>%
  arrange(n)

# Odp: Pytanie mo�na r�nie interpretowa�, poniewa� s� 4 kolory,
# kt�re s� najmniej popularne i ka�dy z nich ma po jednym reprezentancie,
# przyjmijmy wi�c �e drugi najmniej popularny kolor to ju� ten kt�ry ma wi�cej 
# ni� 1 reprezentanta, czyli granatowy-metallic.



# 10. Jaka jest wartość kwantyla 0.25 oraz 0.75 pojemności skokowej dla 
# samochodów marki Volkswagen w zależności od tego, czy w ich wyposażeniu 
# dodatkowym znajdują się elektryczne lusterka?


auta2012 %>%
  filter(Marka == "Volkswagen") %>%
  mutate(Lusterka = ifelse(grepl('el. lusterka', Wyposazenie.dodatkowe),"tak","nie")) %>%
  group_by(Lusterka) %>%
  #grepl('pattern',vect) zwraca TRUE, je�li string vect zawiera 'pattern'
  summarize(kwantyl25 = quantile(Pojemnosc.skokowa, probs = 0.25, na.rm = TRUE), 
            kwantyl75 = quantile(Pojemnosc.skokowa, probs = 0.75, na.rm = TRUE))
  

# Odp: Dla aut z elektrycznymi lusterkami warto�� kwantyla 0.25 wynosi 1892,
# warto�� kwantyla 0.75 wynosi 1968,
# natomiast dla aut bez elektrycznych lusterek
# warto�� kwantyla 0.25 wynosi 1400, warto�� kwantyla 0.75 wynosi 1900


