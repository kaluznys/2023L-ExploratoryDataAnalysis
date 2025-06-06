library(PogromcyDanych)
data(auta2012)
library(stringr)



# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?

auta2012 %>% 
  filter(Waluta == "PLN" & Rodzaj.paliwa == "naped elektryczny") %>% 
  summarise(median(Cena))

# Odp: 18900



# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.

auta2012 %>% 
  filter(Rok.produkcji != "" & !is.na(KM) &  Marka != "") %>% 
  mutate(po.2001 = ifelse(Rok.produkcji >= 2001, TRUE, FALSE)) %>% 
  group_by(Marka, po.2001) %>% 
  summarise(mediana = median(KM)) %>% 
  arrange(desc(mediana)) %>% 
  head(1) 

# Odp: Mediana liczby koni mechanicznych najwi�ksza jak dla Bugatti wyprodukowanym
# w 2021 roku lub p�niej i wynosi 1001.



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.

auta2012 %>% 
  filter(Kolor == "szary-metallic" &
           between(Cena.w.PLN, median(Cena.w.PLN), mean(Cena.w.PLN)) &
           as.character(Kraj.aktualnej.rejestracji) != as.character(Kraj.pochodzenia)) %>% 
  summarise(n())

# Odp:1930



# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?

auta2012 %>% 
  filter(Model == "Passat" &
           Wersja == "B6" &
           Rodzaj.paliwa == "benzyna") %>% 
  summarise(IQR(Przebieg.w.km, na.rm = TRUE))

# Odp: 75977.5



# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).

auta2012 %>% 
  filter(Waluta == "CZK") %>% 
  mutate(cena.brutto = ifelse(Brutto.netto == "brutto",
                              Cena.w.PLN, Cena.w.PLN * 1.02)) %>% 
  summarise(mean(cena.brutto))

# Odp: 36047.06



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.

# Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�?
auta2012 %>% 
  filter(Marka == "Chevrolet" &
           Przebieg.w.km > 50000 &
           Skrzynia.biegow != "") %>%
  group_by(Skrzynia.biegow) %>% 
  summarise(Ilosc = n()) %>% 
  arrange(desc(Ilosc)) %>% 
  slice_head(n = 1L)

# Model, kt�ry najcz�ciej pojawia si� w obu przypadkach.
auta2012 %>% 
  filter(Marka == "Chevrolet" &
           Przebieg.w.km > 50000 &
           Skrzynia.biegow != "") %>%
  group_by(Skrzynia.biegow, Model) %>% 
  summarise(Ilosc = n()) %>% 
  arrange(desc(Ilosc)) %>% 
  slice_head(n = 1L)

# Odp: Chevrolet�w z przebiegiem wi�kszym ni� 50 000 z manualn� skrzyni� bieg�w 
# jest wi�cej. Corvette to model, kt�ry pojawia si� najcz�ciej jako samoch�d
# z automatyczn� skrzyni� bieg�w, za� Lacetti- z manualn� skrzyni�.



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>% 
  filter(Marka == "Mercedes-Benz" &
           Pojemnosc.skokowa != "") %>% 
  mutate(przed.2003 = ifelse(Rok.produkcji <= 2003, Pojemnosc.skokowa, NA)) %>% 
  mutate(po.2003 = ifelse(Rok.produkcji > 2003, Pojemnosc.skokowa, NA)) %>% 
  summarise(mediana_przed_2003 = median(przed.2003, na.rm = TRUE),
            mediana_po_2003 = median(po.2003, na.rm = TRUE))

# Odp: Mediana nie zmieni�a si�



# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?

auta2012 %>% 
  filter(Kraj.aktualnej.rejestracji == "Polska" &
           Kraj.pochodzenia == "Niemcy" &
           Przebieg.w.km != "") %>% 
  summarise(max(Przebieg.w.km))

# Odp: 1e+09



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?

auta2012 %>% 
  filter(Marka == "Mitsubishi" &
           Kraj.pochodzenia == "Wlochy" &
           Kolor != "") %>% 
  group_by(Kolor) %>% 
  summarise(Ilosc = n()) %>% 
  arrange((Ilosc))

# Odp: Drugi, najmniej popularnym kolorem jest granatowy_metallic.



# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?

auta2012 %>% 
  filter(Marka == "Volkswagen" & 
           str_detect(Wyposazenie.dodatkowe, "el. lusterka") == TRUE) %>% 
  summarise(kwantyl_0.25 = quantile(Pojemnosc.skokowa, 0.25, na.rm = TRUE),
            kwantyl_0.75 = quantile(Pojemnosc.skokowa, 0.75, na.rm = TRUE))
  
# Odp:kwantyl_0.25 kwantyl_0.75
#      1892.25         1968