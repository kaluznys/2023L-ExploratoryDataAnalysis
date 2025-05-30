library(ggplot2)
library(maps)
library(dplyr)
library(readxl)

francja <- map_data('france')

zarobki <- read_xlsx("salary.xlsx")

zarobki %>% 
  transmute(salary, region = stri_trans_general(region, id = "Latin-ASCII")) %>% 
  mutate(salary.cat = case_when(salary < 14 ~ '1', salary >= 14 & salary < 15 ~ '2',
                                salary >= 15 & salary < 16 ~ '3', salary >= 16 & salary < 18 ~ '4',
                                salary > 18 ~ '5'))-> zarobki_ba



left_join(francja, zarobki_ba, by = "region") -> fr_zarobki


fr_zarobki %>% 
  ggplot() +
  geom_polygon(aes(x = long, y = lat, fill = salary.cat, group = group)) +
  coord_fixed(1.3) +
  scale_fill_manual(values = c('#feebe2','#fbb4b9','#f768a1','#c51b8a','#7a0177'),
                    name = "",
                    labels = c("<14", "14-15", "15-16", "16-18", ">18", "brak danych")) +
  theme(legend.position = "right",
        panel.background = element_blank(),
        axis.text = element_blank(),
        axis.line = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank()) +
  ggtitle("Średnie wynagrodzenie netto w euro za godzinę pracy",
          subtitle = "w poszczególnych departamentach Francji w 2022 roku")-> fr_salary

fr_salary




