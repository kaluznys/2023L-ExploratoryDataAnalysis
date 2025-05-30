install.packages("PogromcyDanych")
library(stringi)
library(stringr)
library(PogromcyDanych)
auta2012

#Autor: Pola Mo渃icka

# 1. Rozwa偶aj膮c tylko obserwacje z PLN jako walut膮 (nie zwa偶aj膮c na 
# brutto/netto): jaka jest mediana ceny samochod贸w, kt贸re maj膮 nap臋d elektryczny?

auta2012 %>% 
  filter(Waluta=="PLN",Rodzaj.paliwa=="naped elektryczny") %>% 
  select(Cena) %>% 
  summarise(med=median(Cena),na.rm=TRUE)

# Odp: 18900

# 2. W podziale samochod贸w na marki oraz to, czy zosta艂y wyprodukowane w 2001 
# roku i p贸藕niej lub nie, podaj kombinacj臋, dla kt贸rej mediana liczby koni
# mechanicznych (KM) jest najwi臋ksza.


auta2012 %>% 
  mutate(podzial = case_when(Rok.produkcji >= "2001" ~ "w 2001/po",
                             Rok.produkcji < "2001" ~ "przed 2001")) %>% 
  filter(!is.na(KM)) %>%                                                
  group_by(Marka, podzial) %>% 
  summarise(med=median(KM)) %>% 
  arrange(-med) 

# Odp: Bugatti, wyprodukowany w/po 2001 (mediana wynosi 1001KM)


#Spo渞骴 samochod體 w kolorze szary-metallic, kt髍ych cena w PLN znajduje si�
# pomi阣zy jej 渞edni� a median� (nie zwa縜j筩 na brutto/netto), wybierz te, 
# kt髍ych kraj pochodzenia jest inny ni� kraj aktualnej rejestracji i poodaj ich liczb�.


auta2012 %>% 
  select(Kolor,Cena.w.PLN,Kraj.aktualnej.rejestracji,Kraj.pochodzenia) %>% 
  filter(Kolor=="szary-metallic") %>% 
  #summarise(srednia=mean(Cena.w.PLN),med=median(Cena.w.PLN)) - mean: 44341.41, mediana:27480, tutaj sobie wyliczy砤m median� i 渞edni� tak dodatkowo
  filter((Cena.w.PLN>median(Cena.w.PLN) & Cena.w.PLN<mean(Cena.w.PLN))|(Cena.w.PLN<median(Cena.w.PLN) & 
                                                                          Cena.w.PLN>mean(Cena.w.PLN)) )%>% 
  filter(!Kraj.pochodzenia%s===%Kraj.aktualnej.rejestracji)  %>% 
  summarize(n=n())

# Odp: 1331



# 4. Jaki jest rozst臋p mi臋dzykwartylowy przebiegu (w kilometrach) Passat贸w
# w wersji B6 i z benzyn膮 jako rodzajem paliwa?

auta2012 %>% 
  select(Model, Wersja, Rodzaj.paliwa, Przebieg.w.km) %>% 
  filter(Model=="Passat", Wersja=="B6", Rodzaj.paliwa=="benzyna") %>%
  filter(!is.na(Przebieg.w.km)) %>% 
  summarise(kw1=quantile(Przebieg.w.km,probs = 0.25),kw3=quantile(Przebieg.w.km,probs = 0.75)) %>% 
  mutate(rozstep = abs(kw3-kw1))


# Odp: 75977.5



# 5. Bior膮c pod uwag臋 samochody, kt贸rych cena jest podana w koronach czeskich,
# podaj 艣redni膮 z ich ceny brutto.
# Uwaga: Je艣li cena jest podana netto, nale偶y dokona膰 konwersji na brutto (podatek 2%).


auta2012 %>% 
  filter(Waluta=="CZK") %>% 
  mutate(Cena.w.PLN.2= case_when(Brutto.netto == "brutto" ~ Cena,Brutto.netto == "netto" ~ Cena*1.02)) %>% 
  summarise(srednia=mean(Cena.w.PLN.2))


# Odp: 210678.3




# 6. Kt贸rych Chevrolet贸w z przebiegiem wi臋kszym ni偶 50 000 jest wi臋cej: tych
# ze skrzyni膮 manualn膮 czy automatyczn膮? Dodatkowo, podaj model, kt贸ry najcz臋艣ciej
# pojawia si臋 w obu przypadkach.

#a)
auta2012 %>% 
  select(Marka, Model, Przebieg.w.km, Skrzynia.biegow) %>% 
  filter(Marka=="Chevrolet", Przebieg.w.km>50000) %>% 
  group_by(Skrzynia.biegow) %>% 
  summarise(count=n())  

#b)
auta2012 %>% 
  select(Marka, Model, Przebieg.w.km, Skrzynia.biegow) %>% 
  filter(Marka=="Chevrolet", Przebieg.w.km>50000) %>% 
  group_by(Model,Skrzynia.biegow) %>% 
  summarise(n=n()) %>% 
  arrange(-n) %>% 
  head(10)


# Odp: a)wi阠ej jest tych ze skrzyni� manualn�,b)Model ktory pojawia si� najcz隃ciej - manualne: Lacetti, automatyczne: Corvette




# 7. Jak zmieni艂a si臋 mediana pojemno艣ci skokowej samochod贸w marki Mercedes-Benz,
# je艣li we藕miemy pod uwag臋 te, kt贸re wyprodukowano przed lub w roku 2003 i po nim?

auta2012 %>% 
  select(Marka, Pojemnosc.skokowa, Rok.produkcji) %>% 
  filter(Marka=="Mercedes-Benz") %>% 
  filter(!is.na(Pojemnosc.skokowa)) %>% 
  summarise(med=median(Pojemnosc.skokowa))
#powy縠j wyliczona mediana pojemno渃i skokowej r體na 2200 marki Mercedes-Benz

auta2012 %>% 
  select(Marka, Pojemnosc.skokowa, Rok.produkcji) %>% 
  filter(Marka=="Mercedes-Benz") %>% 
  filter(!is.na(Pojemnosc.skokowa)) %>% 
  mutate(podzial = case_when(Rok.produkcji > "2003" ~ "po",
                             Rok.produkcji <= "2003" ~ "przed")) %>% 
  group_by(podzial) %>% 
  summarise(med=median(Pojemnosc.skokowa))


# Odp: mediana si� nie zmieni砤 



# 8. Jaki jest najwi臋kszy przebieg w samochodach aktualnie zarejestrowanych w
# Polsce i pochodz膮cych z Niemiec?

auta2012 %>% 
  select(Marka, Przebieg.w.km, Kraj.aktualnej.rejestracji, Kraj.pochodzenia) %>% 
  filter(Kraj.aktualnej.rejestracji =="Polska", Kraj.pochodzenia=="Niemcy") %>% 
  filter(!is.na(Przebieg.w.km)) %>% 
  arrange(-Przebieg.w.km) %>% 
  head(1)
   


# Odp: 1e+09 (dok砤dnie: 999999999)



# 9. Jaki jest drugi najmniej popularny kolor w samochodach marki Mitsubishi
# pochodz膮cych z W艂och?

auta2012 %>% 
  select(Marka, Kraj.pochodzenia, Kolor) %>% 
  filter(Marka=="Mitsubishi", Kraj.pochodzenia=="Wlochy") %>% 
  group_by(Kolor) %>% 
  summarise(popularny_kolor=n()) %>% 
  arrange(popularny_kolor) %>% 
  head(10)

# Odp: granatowy-metallic (uzna砤m. 縠 te cztery kt髍e wyst阷uj� tylko 1 raz zajmuj� ex aequo pierwsze miejsce)



# 10. Jaka jest warto艣膰 kwantyla 0.25 oraz 0.75 pojemno艣ci skokowej dla 
# samochod贸w marki Volkswagen w zale偶no艣ci od tego, czy w ich wyposa偶eniu 
# dodatkowym znajduj膮 si臋 elektryczne lusterka?

auta2012 %>% 
  select(Marka, Pojemnosc.skokowa, Wyposazenie.dodatkowe) %>% 
  filter(Marka=="Volkswagen") %>%
  
  #tutaj sprawdza砤m czy jest informacja o tych lusterkach i je渓i jest to zamienia砤m na informacje tak, wpp nie
  mutate(lusterka=case_when( stri_detect_fixed(Wyposazenie.dodatkowe, "el. lusterka")==TRUE ~ "tak", 
                             stri_detect_fixed(Wyposazenie.dodatkowe, "el. lusterka")==FALSE ~ "nie")) %>% 
  filter(!is.na(Pojemnosc.skokowa)) %>% 
  select(Marka, Pojemnosc.skokowa, lusterka) %>% 
  group_by(lusterka) %>% 
  
  summarise(kw1=quantile(Pojemnosc.skokowa,probs = 0.25),kw2=quantile(Pojemnosc.skokowa,probs = 0.75)) 



# Odp: Warto滄 kwantyla 0.25 dla samochod體 z lusterkami elektrycznymi wynosi 1892, a dla tych bez wynosi 1400.
#      Warto滄 kwantyla 0.75 dla samochod體 z lusterkami elektrycznymi wynosi 1968, a dla tych bez wynosi 1900.


