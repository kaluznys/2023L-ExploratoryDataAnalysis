library(PogromcyDanych)
library(dplyr)
data(auta2012)


# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?

auta2012 %>% 
  filter(Rodzaj.paliwa == "naped elektryczny" & Waluta == "PLN") %>% 
  select(Cena) %>% 
  pull %>% 
  median
  

# Odp:  18900



# 2.W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.

auta2012 %>% 
  group_by(Marka, Wyprodukowane.po.2001 = ifelse(Rok.produkcji >= 2001, "tak", "nie")) %>% 
  summarise(Mediana.KM = median(KM), .groups = "keep") %>% 
  arrange(desc(Mediana.KM)) %>% 
  select(Marka, Wyprodukowane.po.2001) %>% 
  head(1)

# Odp: Bugatti , nie



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.
# UWAGA: Nie rozpatrujemy obserwacji z NA w kraju aktualnej rejestracji

auta2012 %>% 
  filter(Kolor == "szary-metallic") %>% 
  filter(Cena.w.PLN %in% median(Cena.w.PLN):mean(Cena.w.PLN)) %>% 
  filter(!is.na(Kraj.aktualnej.rejestracji)) %>% 
  filter(as.character(Kraj.pochodzenia) != as.character(Kraj.aktualnej.rejestracji)) %>% 
  pull %>% 
  length

# Odp: 1071



# Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w w wersji B6 i z benzyn� jako rodzajem paliwa?

auta2012 %>% 
  filter(Marka == "Volkswagen" & Model == "Passat" & Wersja == "B6" & Rodzaj.paliwa == "benzyna") %>% 
  select(Przebieg.w.km) %>% 
  pull %>% 
  IQR(na.rm = T)

# Odp: 75977.5



# 5.  Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich 
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).

auta2012 %>% 
  filter(Waluta == "CZK") %>% 
  mutate(Cena.brutto = ifelse(Brutto.netto == "netto", 1.23 * Cena, Cena)) %>% 
  pull %>% 
  mean

# Odp: 227796.8 CZK



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.

DF <- auta2012 %>% 
  filter(Marka == "Chevrolet" & Przebieg.w.km > 50000) %>% 
  group_by(Skrzynia.biegow, Model) %>% 
  count %>% 
  arrange(desc(n))

DF %>% 
  group_by(Skrzynia.biegow) %>% 
  summarise(n = sum(n))

# Odp: Wiecej jest Chevroletow ze srzynia manualna (336) niz automatyczna (112). 
# Skrzynia manualna - model Lacetti (94), skrzynia automatyczna - model Corvette (20).



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>% 
  filter(Marka == "Mercedes-Benz") %>% 
  group_by(Wyprodukowane.przed.2003 = ifelse(Rok.produkcji <= 2003, "tak", "nie")) %>% 
  summarise(mediana = median(Pojemnosc.skokowa, na.rm = T))



# Odp: Nie zmienila sie



# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?

auta2012 %>% 
  filter(Kraj.aktualnej.rejestracji == "Polska" & Kraj.pochodzenia == "Niemcy") %>% 
  arrange(desc(Przebieg.w.km)) %>% 
  select(Przebieg.w.km) %>% 
  head(1)

# Odp: 1000000000 km (ciekawe)



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?

auta2012 %>% 
  filter(Marka == "Mitsubishi" & Kraj.pochodzenia == "Wlochy") %>% 
  group_by(Kolor) %>% 
  count %>% 
  arrange(n) 
 
# Odp: granatowy-metallic



# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?

auta2012 %>% 
  filter(Marka == "Volkswagen" & grepl("el. lusterka", Wyposazenie.dodatkowe)) %>% 
  select(Pojemnosc.skokowa) %>% 
  pull %>% 
  quantile(na.rm = T)

# Odp: Q1 = 1892.25, Q3 = 1968.0


