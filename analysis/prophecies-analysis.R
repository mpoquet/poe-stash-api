#!/usr/bin/env Rscript
library(tidyverse)
library(viridis)
library(treemap)
library(tidytext)

theme_set(theme_bw())

raw_data1 = read_csv('character-level-1.csv', comment='#')
raw_data1b = read_csv('character-level-1-block.csv', comment='#')
raw_data30 = read_csv('character-level-30.csv', comment='#')
seal_cost = read_csv('prophecies-seal-cost.csv', comment='#')
tiers = read_csv('prophecies-tiers.csv', comment='#')

nb_prophecies_per_method = sum(raw_data1$count)
stopifnot(sum(raw_data1b$count) == nb_prophecies_per_method)
stopifnot(sum(raw_data30$count) == nb_prophecies_per_method)

full_data = inner_join(
  full_join(
    full_join(
      raw_data1 %>% transmute(item=item, "level 1 no blocking"=count),
      raw_data1b %>% transmute(item=item, "level 1 blocking"=count),
    ),
      raw_data30 %>% transmute(item=item, "level 30 no blocking"=count)
  ) %>% replace(is.na(.), 0),
  inner_join(tiers, seal_cost)
)
write_csv(full_data, '/tmp/prophecies-data.csv')

longer_data = pivot_longer(full_data, cols=2:4,
  names_to="method",
  values_to="count"
) %>% filter(count>0) %>% mutate(
  total_silver_cost = count * (seal_cost+1),
  proba = count / nb_prophecies_per_method
) %>% mutate(
  stderr=sqrt((proba*(1-proba))/nb_prophecies_per_method)
)

ggplot(longer_data,
    aes(x=reorder_within(item, proba, method), y=proba, fill=tier)) +
  geom_bar(stat = "identity") +
  geom_errorbar(aes(ymin=proba-1.96*stderr, ymax=proba+1.96*stderr), width=0.5) +
  coord_flip() +
  scale_x_reordered() +
  scale_y_continuous(expand=c(0.001,0.001), labels=scales::percent,
    breaks=seq(from=0,to=0.1, by=0.02)
  ) +
  scale_fill_viridis(discrete=TRUE, begin=0.2) +
  facet_grid(rows=vars(method), scales="free", space="free") +
  labs(y="Probability of occurrence") +
  theme(
    legend.direction = "horizontal",
    legend.position = c(0.8,0.025),
    legend.title = element_blank(),
    axis.title.y = element_blank(),
    axis.text = element_text(size=8),
    legend.background = element_blank(),
    legend.box.background = element_rect(color="black"),
  ) +
  ggsave('/tmp/prophecies-probability-barchart.png', width=8, height=16)

ggplot(longer_data %>% filter(method=="level 1 no blocking"),
    aes(x=reorder_within(item, total_silver_cost, method), y=total_silver_cost, fill=tier)) +
  geom_bar(stat = "identity", show.legend=FALSE) +
  coord_flip() +
  scale_x_reordered() +
  scale_y_continuous(expand=c(0.01,0.01)) +
  scale_fill_viridis(discrete=TRUE, begin=0.2) +
  facet_grid(rows=vars(method), scales="free", space="free") +
  labs(y="Total amount of silver coins used") +
  theme(
    axis.title.y = element_blank(),
    axis.text = element_text(size=8),
    legend.background = element_blank(),
    legend.box.background = element_rect(color="black"),
  ) +
  ggsave('/tmp/prophecies-silver-waste-lvl1-barchart.png', width=8, height=4)


silver_cost_per_method = longer_data %>%
  group_by(method) %>%
  summarize(method_cost=sum(total_silver_cost))

silver_cost_per_methodtier = longer_data %>%
  group_by(method, tier) %>%
  summarize(methodtier_cost=sum(total_silver_cost))

silver_cost = inner_join(
  silver_cost_per_method,
  silver_cost_per_methodtier
) %>% mutate(
  fraction_cost=methodtier_cost/method_cost
) %>% mutate(
  stderr=sqrt((fraction_cost*(1-fraction_cost))/method_cost)
)

silver_cost %>% ggplot(aes(x=tier, y=fraction_cost, fill=tier)) +
  geom_bar(stat="identity", show.legend=FALSE) +
  geom_errorbar(aes(ymin=fraction_cost-1.96*stderr, ymax=fraction_cost+1.96*stderr), width=0.5) +
  scale_fill_viridis(discrete=TRUE, begin=0.2) +
  scale_y_continuous(labels=scales::percent) +
  facet_wrap(vars(method)) +
  labs(y="Proportion of silver coins spent") +
  theme(
    axis.title.x = element_blank()
  ) +
  ggsave('/tmp/prophecies-silver-cost.png', width=8, height=4)
