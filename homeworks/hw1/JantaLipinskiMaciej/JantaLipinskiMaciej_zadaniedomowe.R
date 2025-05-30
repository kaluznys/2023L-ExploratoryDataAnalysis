library(stringr)
library(PogromcyDanych)
data(auta2012)


# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?

auta2012 %>% 
  filter(Rodzaj.paliwa == "naped elektryczny") %>% 
  summarise(mediana = median(Cena.w.PLN, na.rm = TRUE))

# Odp: 19600 (hybrydy nie by�y liczone do aut elektrycznych)


# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.

auta2012 %>% 
  mutate(przed_i_po = ifelse(Rok.produkcji <= 2001, "przed", "po")) %>% 
  group_by(Marka) %>% 
  summarise(mediana = median(KM, na.rm = TRUE)) %>% 
    top_n(1, mediana)

# Odp: Bugatti po 2001 (2009 rok) 1001KM


# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.


# srednia wi�ksza od mediany

auta2012 %>% 
  filter(Kolor == "szary-metallic",
         median(auta2012$Cena.w.PLN, na.rm = TRUE) <= Cena.w.PLN 
         & Cena.w.PLN <= mean(auta2012$Cena.w.PLN, na.rm = TRUE),
         is.na(Kraj.aktualnej.rejestracji) == FALSE, is.na(Kraj.pochodzenia) == FALSE,
         as.character(Kraj.pochodzenia) != as.character(Kraj.aktualnej.rejestracji)) %>% 
  summarise(n = n())

 
# Odp: 1930

# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?

auta2012 %>% 
  filter(Marka == "Volkswagen", Model == "Passat", Wersja == "B6", Rodzaj.paliwa == "benzyna",
         is.na(Przebieg.w.km) == FALSE ) %>% 
  summarise(kwartyle = IQR(Przebieg.w.km))
  
# Odp: 75977.5


# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).

auta2012 %>% 
  filter(Waluta == "CZK") %>% 
  mutate(converter = ifelse(Brutto.netto == "brutto", 1, 1.02), prize_brutto = Cena*converter) %>% 
  summarise(srednia_cena_brutto = mean(prize_brutto, na.rm = TRUE))



# Odp: 210678.3 (36047.06 w z�ot�wkach)



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.

# czy wiecej manualna, czy automatyczna, spos�b 1
auta2012 %>% 
  filter(Marka == "Chevrolet", Przebieg.w.km >= 50000)%>% 
  mutate(automatic = ifelse(Skrzynia.biegow == "automatyczna", 1, 0),
         manual = ifelse(Skrzynia.biegow == "manualna", 1, 0)) %>% 
  summarize(automatyczna = sum(automatic, na.rm = TRUE), manualna = sum(manual, na.rm = TRUE)) 

# czy wiecej manualna, czy automatyczna, spos�b 2 (zapewne lepszy)
auta2012 %>% 
  filter(Marka == "Chevrolet", Przebieg.w.km >= 50000, Skrzynia.biegow != "")%>% 
  group_by(Skrzynia.biegow) %>% summarise(ilosc = n())

# kt�rych modeli z automatyczn� i manualn� najwi�cej
auta2012 %>% 
  filter(Marka == "Chevrolet", Przebieg.w.km >= 50000, 
         Skrzynia.biegow == "manualna" |Skrzynia.biegow == "automatyczna")%>% 
  select(Marka,Model, Skrzynia.biegow, Przebieg.w.km) %>% group_by(Skrzynia.biegow, Model) %>% 
  summarise(n = n()) %>% arrange(-n)


# Odp: wi�cej z manualn�, najwi�cej ze skrzyni� manualn� jest Lacetti
# a z automatyczn� Corvette



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>%
  mutate(przed_i_po = ifelse(Rok.produkcji <= 2003, "przed", "po")) %>% 
  group_by(przed_i_po) %>% 
  summarise(mediana = median(Pojemnosc.skokowa, na.rm = TRUE))

# Odp: Mediana pojemno�ci skokowej zwi�kszy�a si� (z 1896 do 1900)


# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?

auta2012  %>% 
  filter(Kraj.aktualnej.rejestracji == "Polska",
         Kraj.pochodzenia == "Niemcy") %>%
  top_n(1, Przebieg.w.km)%>% 
  select(Marka, Przebieg.w.km, Kraj.aktualnej.rejestracji, Kraj.pochodzenia)

# Odp: Najwi�kszy przebieg to 1e+09 (1.000.000.000), w samochodzie marki Mercedes-Benz



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?

auta2012 %>% 
  filter(Marka == "Mitsubishi", Kraj.pochodzenia == "Wlochy", Kolor != "") %>% 
  group_by(Kolor) %>% 
  summarise(liczba_aut = n()) %>% 
  arrange(liczba_aut)

# Odp: granatowy-metallic


# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?

auta2012 %>% 
  filter(Marka == "Volkswagen") %>%
  mutate(czy_sa = ifelse(str_detect(Wyposazenie.dodatkowe, "el. lusterka"), TRUE, FALSE)) %>% 
  group_by(czy_sa) %>% 
  summarise(x = quantile(Pojemnosc.skokowa, probs = seq(0.25, 0.75, 0.5), na.rm = TRUE))

# Odp: gdy nie ma lusterek elektrycznych to warto�� kwantyla 0.25, wynosi 1400, 
# a kwantyla 0.75 wynosi 1900, odpowiednio gdy s� kwantyl 0.25 to 1892, a kwantyl 
# 0.75 to 1968

