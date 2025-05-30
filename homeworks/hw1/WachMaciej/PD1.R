library("dplyr")
library("PogromcyDanych")
library("stringi")
data(auta2012)

# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?

auta2012 %>% 
  filter(Waluta == "PLN", Rodzaj.paliwa == "naped elektryczny") %>% 
  summarise(mediana.ceny = median(Cena, na.rm = TRUE))

# Odp: 18900



# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.

auta2012 %>% 
  mutate(w.2001.lub.po = ifelse(Rok.produkcji >=2001,"tak","nie")) %>% 
  group_by(Marka, w.2001.lub.po) %>% 
  summarise(mediana.KM = median(KM, na.rm = TRUE)) %>% 
  arrange(-mediana.KM) %>% 
  head(1)

# Odp: Bugatti, wyp. po 2001r, mediana KM: 1001



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.

auta2012 %>% 
  filter(Kolor == "szary-metallic") %>% 
  filter((Cena.w.PLN > median(Cena.w.PLN) & Cena.w.PLN < mean(Cena.w.PLN)) | (Cena.w.PLN < median(Cena.w.PLN) & Cena.w.PLN > mean(Cena.w.PLN))) %>% 
  filter(! Kraj.pochodzenia %s===% Kraj.aktualnej.rejestracji) %>% 
  summarise(n = n())

# Odp: 1331



# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?

auta2012 %>% 
  filter(Model == "Passat", Wersja == "B6", Rodzaj.paliwa == "benzyna") %>% 
  summarise(RQ = quantile(Przebieg.w.km, probs = 0.75, na.rm = T) - quantile(Przebieg.w.km, probs = 0.25, na.rm = T))

# Odp: 75977.5



# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).

auta2012 %>% 
  filter(Waluta == "CZK") %>% 
  mutate(cena.brutto = ifelse(Brutto.netto == "brutto", Cena, 1.02 * Cena)) %>% 
  summarise(srednia.brutto = mean(cena.brutto))

# Odp:	210678.3



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.

auta2012 %>% 
  filter(Przebieg.w.km > 50000, Marka == "Chevrolet") %>% 
  group_by(Skrzynia.biegow) %>% 
  summarise(n = n()) %>% 
  arrange(-n)

auta2012 %>% 
  filter(Przebieg.w.km > 50000, Marka == "Chevrolet") %>% 
  group_by(Model, Skrzynia.biegow) %>% 
  summarise(n = n()) %>% 
  arrange(-n)

# Odp: 1) manualna 2) manualna - Lacetti, automatyczna - Corvette



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>% 
  filter(Marka == "Mercedes-Benz") %>% 
  mutate(okres.produkcji = ifelse(Rok.produkcji <= 2003, "przed lub w 2003", "po 2003")) %>% 
  group_by(okres.produkcji) %>% 
  summarise(mediana.poj.skokowej = median(Pojemnosc.skokowa, na.rm = T))

# Odp: Taka sama (2200)



# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?

auta2012 %>% 
  filter(Kraj.pochodzenia == "Niemcy", Kraj.aktualnej.rejestracji == "Polska") %>%
  arrange(-Przebieg.w.km) %>% 
  select(Przebieg.w.km) %>% 
  head(1)

# Odp: 1e+09 / 999999999



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?

auta2012 %>% 
  filter(Kraj.pochodzenia == "Wlochy", Marka == "Mitsubishi") %>%
  group_by(Kolor) %>% 
  summarise(n = n()) %>% 
  arrange(n)

# Odp: granatowy-metallic



# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?

auta2012 %>% 
  filter(Marka == "Volkswagen") %>% 
  mutate(ma.el.lusterka = ifelse(stri_detect_fixed(Wyposazenie.dodatkowe, "el. lusterka")==TRUE, "tak", "nie")) %>% 
  group_by(ma.el.lusterka) %>% 
  summarise(Q1 = quantile(Pojemnosc.skokowa, probs = 0.25, na.rm = T),
            Q3 = quantile(Pojemnosc.skokowa, probs = 0.75, na.rm = T))

# Odp: dla maj�cych el. lusterka: kwantyl 0.25 = 1892, kwantyl 0.75 = 1968
# dla nie maj�cych el. lusterek: kwantyl 0.25 = 1400, kwantyl 0.75 = 1900
