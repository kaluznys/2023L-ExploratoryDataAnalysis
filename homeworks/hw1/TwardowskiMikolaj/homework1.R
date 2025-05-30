library(PogromcyDanych)
library(dplyr)
library(stringr)

data(auta2012)

#Mikolaj Twardowski
# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?




wynik1 <- filter(auta2012, Rodzaj.paliwa == "naped elektryczny", Waluta == "PLN")
wynik1 %>% 
  group_by(Rodzaj.paliwa) %>% 
  summarise(mediana = median(Cena, na.rm = TRUE))
# Odp:18900

# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.



wynik2 <- mutate(auta2012, pozniej_niz_2001 = ifelse(Rok.produkcji >= 2001, "yes", "no"))
wynik2 <- group_by(wynik2,Marka,pozniej_niz_2001)
wynik2 <- summarise(wynik2, mediana = median(KM, na.rm = TRUE))
wynik2 <- arrange(wynik2,desc(mediana))  

head(wynik2,1)
# Odp: Bugatti, 1001

# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.
# UWAGA: Nie rozpatrujemy obserwacji z NA w kraju aktualnej rejestracji



# Odp:

wynik3 <- filter(auta2012, Kolor == "szary-metallic")
wynik3 <- mutate(wynik3, mediana = median(Cena, na.rm = TRUE))
wynik3 <- mutate(wynik3, srednia = mean(Cena, na.rm = TRUE))
wynik3 <- mutate(wynik3, ifelse(Kraj.pochodzenia == Kraj.aktualnej.rejestracji), 0,1)

head(wynik3)

# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?



wynik4 <- filter(auta2012,Model == "Passat", Wersja == "B6", Rodzaj.paliwa == "benzyna")
kwartale <- quantile(wynik4["Przebieg.w.km"],na.rm = TRUE, probs = c(0,0.25,0.5,0.75,1))
rozstep_miedzykwartalowy <- (kwartale[4] - kwartale[2])

rozstep_miedzykwartalowy
# Odp:75977.5 

# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).



wynik5 <- filter(auta2012, Waluta == "CZK")
wynik5 <- mutate(wynik5, CenaBrutto = ifelse(Brutto.netto == "netto",Cena *1.02,Cena ))

summarise(wynik5,mean = mean(CenaBrutto, na.rm = TRUE))

# Odp: 210678.3

# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.




wynik6 <- filter(auta2012, Marka == "Chevrolet",Przebieg.w.km > 50000)
wynik6_1 <- aggregate(wynik6$Skrzynia.biegow, by=list(wynik6$Skrzynia.biegow), FUN=length)
wynik6_1 <- arrange(wynik6_1,desc(x))  

#odpowiedz na to, jakich chevroletow jest wi�cej, manualnych czy automatycznych.
# Odp: Manualnych.
head(wynik6_1,1)


wynik6 <- aggregate(wynik6$Skrzynia.biegow, by=list(Skrzynia.biegow = wynik6$Skrzynia.biegow,Model = wynik6$Model), FUN=length)
wynik6 <- arrange(wynik6,desc(x)) 
wynik6_2 <- filter(wynik6, Skrzynia.biegow == "manualna")
wynik6_3 <- filter(wynik6, Skrzynia.biegow == "automatyczna")

#odpowiedz jakie to s� modele, pierwsza odpowiedz to najwiecej modeli z manualna
#druga odpowiedz to najwieksza ilosc modeli z automatycna
head(wynik6_2,1)
head(wynik6_3,1)
# Odp: Lacetti, Corvette 

# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?



wynik7 <- filter(auta2012,Marka == "Mercedes-Benz")
wynik7 <- mutate(wynik7, po_2003 = ifelse(Rok.produkcji <= 2003, "no", "yes"))

#podzielenie dataframe na dwa mniejsze, gdzie w jednym sa tylko daty po 2003, a w drugim pozostale

wynik7_1 <- subset(wynik7,po_2003 %in% c("yes"))
wynik7_2 <- subset(wynik7,po_2003 %in% c("no"))


wynik7_1 <- summarise(wynik7_1, mediana = median(Pojemnosc.skokowa, na.rm = TRUE))
wynik7_2 <- summarise(wynik7_2, mediana = median(Pojemnosc.skokowa, na.rm = TRUE))


head(wynik7_1)
head(wynik7_2)

# Odp: Mediana pojemnosci skokowej w latach przed lub w roku 2003 i po nim nie zmienila sie


# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?



wynik8 <- filter(auta2012, Kraj.aktualnej.rejestracji == "Polska", Kraj.pochodzenia == "Niemcy")
wynik8 <- arrange(wynik8,desc(Przebieg.w.km))  

head(wynik8$Przebieg.w.km,1)
# Odp: 1e+09


# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?



wynik9 <- filter(auta2012, Marka == "Mitsubishi", Kraj.pochodzenia == "Wlochy")
wynik9 <- aggregate(wynik9$Kolor, by=list(Kolor = wynik9$Kolor), FUN=length)
wynik9 <- arrange(wynik9,x)

#najmniej popularnych kolorow jest az 4, gdyz 4 kolory pojawiaja sie tylko raz w autach w takim ustawieniu
# w moim zrozumieniu zatem drugi najmniej popularny kolor oznacza druga od dolu idac ilosc popularnosci koloru
# czyli w tym przypadku jest to granatowy-mettalic.
head(wynik9)
#Odp:
#najmniej popularnych kolorow jest az 4, gdyz te 4 kolory pojawiaja sie tylko raz w autach w takim ustawieniu
# w moim zrozumieniu zatem drugi najmniej popularny kolor oznacza druga od dolu idac iloscia popularnosci kolorow,
# czyli w tym przypadku jest to granatowy-mettalic.

# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?


wynik10 <- filter(auta2012, Marka == "Volkswagen")
sortowanie <- grepl('el. lusterka', wynik10$Wyposazenie.dodatkowe)

wynik10_1 <- filter(wynik10,sortowanie)
wynik10_2 <- filter(wynik10,!sortowanie)

kwantyle <- quantile(wynik10_1["Pojemnosc.skokowa"],na.rm = TRUE, probs = c(0,0.25,0.5,0.75,1))
kwantyle_2 <- quantile(wynik10_2["Pojemnosc.skokowa"],na.rm = TRUE, probs = c(0,0.25,0.5,0.75,1))

head(wynik10_1,20)


#Kwantyle 0.25 i 0.75 dla Volkswagenow z elektrycznymi lusterkami
kwantyle[2]
kwantyle[4]
#Odp: Kwantyle 0.25 i 0.75 dla Volkswagenow z elektrycznymi lusterkami to 1892.25 i 1968.


kwantyle_2[2]
kwantyle_2[4]
#Odp: Kwantyle 0.25 i 0.75 dla Volkswagenow bez elektrycznych lusterkek to 1400 i 1900