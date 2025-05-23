install.packages("PogromcyDanych")
library(PogromcyDanych)
library(dplyr)
library(tidyr)
auta2012

data(auta2012)

# 1. Rozwa�aj�c tylko obserwacje z PLN jako walut� (nie zwa�aj�c na 
# brutto/netto): jaka jest mediana ceny samochod�w, kt�re maj� nap�d elektryczny?


auta2012%>%select(Rodzaj.paliwa)%>%distinct()
# Odp: 18900
auta2012%>%filter(Rodzaj.paliwa=="naped elektryczny",Waluta=="PLN")%>%select(Cena)%>%summarise(across(Cena, median))


# 2. W podziale samochod�w na marki oraz to, czy zosta�y wyprodukowane w 2001 
# roku i p�niej lub nie, podaj kombinacj�, dla kt�rej mediana liczby koni
# mechanicznych (KM) jest najwi�ksza.



# Odp: Bugatti po 2001 roku

auta2012  %>% select(Marka,Rok.produkcji,KM)%>%
  mutate(nowy=if_else(Rok.produkcji >= 2001,"po2001","stare"))%>%
  select(Marka,nowy,KM)%>%  group_by(Marka,nowy)%>%
  summarise(mediana = median(KM,na.rm=T))%>%arrange(desc(mediana))



# 3. Spo�r�d samochod�w w kolorze szary-metallic, kt�rych cena w PLN znajduje si�
# pomi�dzy jej �redni� a median� (nie zwa�aj�c na brutto/netto), wybierz te, 
# kt�rych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.
# UWAGA: Nie rozpatrujemy obserwacji z NA w kraju aktualnej rejestracji
mediana<-auta2012  %>% filter(Kolor=="szary-metallic",!Kraj.aktualnej.rejestracji=="")%>%
  summarise(across(Cena, median))
mediana<-pull(mediana,Cena)
srednia<-auta2012  %>% filter(Kolor=="szary-metallic",!Kraj.aktualnej.rejestracji=="")%>%
  summarise(across(Cena, mean))
srednia<-pull(srednia,Cena)
auta2012%>%filter(Cena>mediana,Cena<srednia,Kolor=="szary-metallic")%>%
  select(Kraj.aktualnej.rejestracji,Kraj.pochodzenia)%>%
  filter(!is.na(Kraj.aktualnej.rejestracji),!Kraj.aktualnej.rejestracji=="")%>%
  filter(as.character(Kraj.aktualnej.rejestracji)!=as.character(Kraj.pochodzenia))%>%
  nrow()
# Odp: 858



# 4. Jaki jest rozst�p mi�dzykwartylowy przebiegu (w kilometrach) Passat�w
# w wersji B6 i z benzyn� jako rodzajem paliwa?

auta2012%>%filter(Model=="Passat",Wersja=="B6",Rodzaj.paliwa=="benzyna")%>%select(Przebieg.w.km)%>%summarise(kwartal=IQR(Przebieg.w.km,na.rm=T))

# Odp: 75977.5



# 5. Bior�c pod uwag� samochody, kt�rych cena jest podana w koronach czeskich,
# podaj �redni� z ich ceny brutto.
# Uwaga: Je�li cena jest podana netto, nale�y dokona� konwersji na brutto (podatek 2%).

auta2012%>%filter(Waluta=="CZK")%>%mutate(podatek=case_when(Brutto.netto=="brutto"~Cena,Brutto.netto=="netto"~Cena*1.02))%>%select(podatek)%>%summarise(m=mean(podatek))
auta2012%>%filter(Waluta=="CZK")%>%select(Cena)
# Odp: 210678.3



# 6. Kt�rych Chevrolet�w z przebiegiem wi�kszym ni� 50 000 jest wi�cej: tych
# ze skrzyni� manualn� czy automatyczn�? Dodatkowo, podaj model, kt�ry najcz�ciej
# pojawia si� w obu przypadkach.
auta2012%>%filter(Marka=="Chevrolet",Przebieg.w.km>50000)%>%select(Skrzynia.biegow,Model)%>%
  group_by(Skrzynia.biegow)%>%summarise(n=n())
auta2012%>%filter(Marka=="Chevrolet",Przebieg.w.km>50000,Skrzynia.biegow=="manualna")%>%select(Model)%>%
  group_by(Model)%>%summarise(n=n())%>%arrange(-n)
auta2012%>%filter(Marka=="Chevrolet",Przebieg.w.km>50000,Skrzynia.biegow=="automatyczna")%>%select(Model)%>%
  group_by(Model)%>%summarise(n=n())%>%arrange(-n)
# Odp: automatyczna=112 manualna=336 Manualnych wi�cej ni� automatycznych Lacetti w manualnych Corvette w automatycznych



# 7. Jak zmieni�a si� mediana pojemno�ci skokowej samochod�w marki Mercedes-Benz,
# je�li we�miemy pod uwag� te, kt�re wyprodukowano przed lub w roku 2003 i po nim?

auta2012%>%filter(Marka=="Mercedes-Benz")%>%
  mutate(rocznik = if_else(Rok.produkcji<=2003,"stare","nowe"))%>%
  select(rocznik,Pojemnosc.skokowa)%>%group_by(rocznik)%>%
  summarise(med=median(Pojemnosc.skokowa,na.rm = T))
# Odp:Nie zmieni�a si� i wynosi 2200



# 8. Jaki jest najwi�kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz�cych z Niemiec?

auta2012%>%filter(Kraj.aktualnej.rejestracji=="Polska",Kraj.pochodzenia=="Niemcy")%>%
  select(Przebieg.w.km)%>%arrange(desc(Przebieg.w.km))%>%slice_head(n=1)

# Odp:999999999 lub te� 1e+09 mo�liwe �e jest to zwyczajnie b��d podczas wpisywania do systemu



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz�cych z W�och?
auta2012%>%filter(Marka=="Mitsubishi",Kraj.pochodzenia=="Wlochy")%>%
  group_by(Kolor)%>%summarise(n=n())%>%arrange(n)


# Odp: jest to granatowy metallic z 2 autami



# 10. Jaka jest warto�� kwantyla 0.25 oraz 0.75 pojemno�ci skokowej dla 
# samochod�w marki Volkswagen w zale�no�ci od tego, czy w ich wyposa�eniu 
# dodatkowym znajduj� si� elektryczne lusterka?

auta2012%>%filter(Marka=="Volkswagen")%>%
  mutate(lusterka = if_else(grepl("el. lusterka",Wyposazenie.dodatkowe),"Ma","nie ma"))%>%
  select(lusterka,Pojemnosc.skokowa)%>%group_by(lusterka)%>%
  summarise(kwantyl1 = quantile(Pojemnosc.skokowa, 0.25,na.rm=T),
            kwantyl3 = quantile(Pojemnosc.skokowa, 0.75,na.rm=T))

# Odp:Maj�ce lusterka elektryczne : 0.25-1892 0.75-1968
#  Nie maj�ce lusterek elektrycznych : 0.25-1400 0.75-1900


