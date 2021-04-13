### R for data science
### Graphics for communication
## comments/notes written down below are from the book (R for data science) written by
## Hadley Wickham and Garrett Grolemund

library(tidyverse)
library(ggplot2)
ggplot(mpg,aes(displ, hwy))+
  geom_point(aes(color = class))+
  geom_smooth(se = FALSE)+
  labs(title = "Fuel efficiency generally decreases with engine size")

# add labs()
# the purpose of a plot title is to summarise the main findings.
# avoid titles that just describe what the plot is.
# subtitle adds additional detail in a smaller font beneath the title
# caption adds text at the botttom right of the plot. Often used to describe source of data.

ggplot(mpg, aes(displ, hwy))+
  geom_point(aes(color = class))+
  geom_smooth(se = FALSE)+
  labs(title = "Fuel efficiency generally decreases with engine size",
       subtitle = "Two seaters (sports cars) are an exception because of their light weight",
       caption = "Data from fueleconomy.gov"
  )

# you can also replace the axis and legend titles with more detailed descriptions and include units

ggplot(mpg,aes(displ,hwy))+
  geom_point(aes(color = class))+
  geom_smooth(se = F)+
  labs(x = "Engine displacement (L)",
       y = "Highway fuel economy (mpg)",
       color = "car type")

# One can also use mathematical equations by substituting " " for quote()

df <- tibble(
  x = runif(10),
  y = runif(10)
)

ggplot(df, aes(x,y))+
  geom_point()+
  labs( 
    x = quote(sum(x[i]^2, i == 1, n)),
    y = quote(alpha + beta+ frac(delta, theta)))

# Annotations

# Label major components of your plot, label individual observations or groups of observations
# use geom_text() which is similar to geom_point() but it has the label aesthetic as well
# it makes it easy to add textual labels to our plots.

best_in_class <- mpg %>% 
  group_by(class) %>% 
  filter(row_number(desc(hwy))==1)

ggplot(mpg,aes(displ,hwy))+
  geom_point(aes(color = class))+
  geom_text(aes(label = model), data = best_in_class)

# this is hard to read because the text overlap each other.
# using geom_label() puts rectangles behind the text to fix that.

ggplot(mpg, aes(displ,hwy))+
  geom_point(aes(color=class))+
  geom_label(aes(label = model),data = best_in_class, nudge_y = 2, alpha = 0.5)

# ggrepel package can be used to fix overlapping of labels.

library(ggrepel)

ggplot(mpg, aes(displ,hwy))+
  geom_point(aes(color = class))+
  geom_point(size = 3, shape = 1, data = best_in_class)+
  ggrepel::geom_label_repel(aes(label = model), data = best_in_class)

# you can also put the labels directly on the plot. Not the best for this data but...

class_avg <- mpg %>% 
  group_by(class) %>% 
  summarise(
    displ = median(displ),
    hwy = median(hwy)
  )

# summarise() overrides group_by()

ggplot(mpg,aes(displ,hwy,colour = class))+
  ggrepel::geom_label_repel(aes(label = class),
                            data = class_avg,
                            size = 6,
                            label.size = 0,
                            segment.color = NA)+
  geom_point()+
  theme(legend.position = "none")

# one can also add a single label on the plot but you need to create a data frame.
# it's convenient to create a new data frame calculating the total values of x and y
label <- mpg %>% 
  summarise(
    displ = max(displ),
    hwy = max(hwy),
    label = "Increasing engine size is \nrelated to decreasing fuel economy."
  )

ggplot(mpg, aes(displ,hwy))+
  geom_point()+
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right")

# if you want the text exactly at the border of the graph, use 'Inf' 
label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = "Increasing engine size is \nrelated to decreasing fuel economy"
)

ggplot(mpg,aes(displ,hwy))+
  geom_point()+
  geom_text(aes(label = label),data = label, vjust = "top", hjust = "right")

# \n manually breaks the text. Another way is to use str_wrap() and set the number of characters you
# want per line.

"Increasing engine size is related to decreasing fuel economy" %>% 
  stringr::str_wrap(width = 40) %>% 
  writeLines()

# commands for vjust(top, bottom, center) and hjust(left, right, top, bottom, center) 

# SCALES
## Axis ticks and legend keys

# breaks and labels are the two functions that affect the appearance of the ticks on the axis and 
# the keys on the legend.

ggplot(mpg, aes(displ,hwy))+
  geom_point()+
  scale_y_continuous(breaks = seq(15,40,by = 5))

# you can use labels in the same way as breaks. You can also set labels to null to suppress
# the labels altogether. *** It is useful for maps or when you can't share the absolute numbers.

ggplot(mpg, aes(displ,hwy))+
  geom_point()+
  scale_x_continuous(label = NULL)+
  scale_y_continuous(label = NULL)

# breaks can also be used when you have few points and you want to show where exactly the points
# stop eg with US presidents;
presidential %>% 
  mutate(id = 33 + row_number()) %>% 
  ggplot(aes(start,id))+
  geom_point(aes(color = party))+
  geom_segment(aes(xend = end, yend = id))+
  scale_x_date(NULL, presidential$start,date_labels = "'%y" )

# the specification of breaks and labels for date and datetime scales is a little different
# date_labels takes a format specification, in the same form as parse_datetime()
# date_breaks (not shown here), takes a string like "2 days" or "1 month"


# Legend layout
# to control the overall position of the legend, you need to use a theme() setting.

base <- ggplot(mpg,aes(displ,hwy))+
  geom_point(aes(color = class))

base + theme(legend.position = "left")
base + theme(legend.position = "top")
base + theme(legend.position = "bottom")
base + theme(lengend.position = "right") # the default

# you can also use legend.position = "none" to suppress the display of the legend altogether
# to control the display of individual legends, use guides() along with guide_legend() or
# guide_colourbar()
# use nrow() to control number of rows in the legend and override.aes() to override one of the 
# aesthetics to make the points bigger esp if you used a low alpha to display many points
# on a plot

ggplot(mpg,aes(displ,hwy))+
  geom_point(aes(color = class))+
  geom_smooth(se = FALSE)+
  theme(legend.position = "bottom")+
  guides(colour = guide_legend(nrow = 1, override.aes = list(size = 4)))

# Replacing a scale
# there are two scales you might want to switch out, continuous position scales and colour
# scales. The same principles apply to all other aesthetics.
# It's very useful to plot transformations of your variable. For example, as we've seen 
# in diamond prices it's easier to see the precise relationship between carat and price if
# we log transform them:

label <- diamonds %>% 
  summarise(
    carat = max(carat),
    price = max(price),
    label = "relationship between carats \nand price without log of each variable"
  )

ggplot(diamonds, aes(carat, price))+
  geom_bin2d()+ # it's a useful alternative to geom_point() in order to avoid overplotting
  annotate("text",
           x = Inf,
           y = Inf,
           label = " shows relationship \nwithout getting log of both variables", vjust = "top", hjust = "right")

ggplot(diamonds, aes(log10(carat),log10(price)))+
  geom_bin2d()+
  annotate("text", # use annotate() instead of making tibble for the label 
           x = Inf,
           y = Inf,
           label = "shows relationship of variables after finding their logs", vjust = "top", hjust = "right")

# problem is the labels of the axes becomes affected. You can get same result by doing the 
# transformation in the scale

ggplot(diamonds, aes(carat, price))+
  geom_bin2d()+
  scale_x_log10()+
  scale_y_log10()

# Useful alternatives are the ColorBrewer scales which have been hand tuned to work better for
# people with common types of colour blindness

ggplot(mpg, aes(displ, hwy))+
  geom_point(aes(color = drv))+
  scale_color_brewer(palette = "Set1")

# Don't forget simpler techniques. If there are just a few colours,
# you can add a redundant shape mapping.This will also help ensure your plot is 
# interpretable in black and white.

ggplot(mpg, aes(displ, hwy))+
  geom_point(aes(color = drv, shape = drv))+
  scale_color_brewer( palette = "Set1")

# When you have a predefined mapping between values and colours, use scale_colour_manual()

presidential %>% 
  mutate(id = 33 + row_number()) %>% 
  ggplot(aes(start,id))+
  geom_point(aes(color = party))+
  geom_segment(aes(xend = end, yend = id))+
  scale_color_manual(values = c(Republican = "red", Democratic = "blue"))

# For continuous colour, you can use the built-in scale_colour_gradient()
# or scale_fill_gradient()
# If you have a diverging scale, you can use scale_colour_gradient2(). That allows you to give,
# for example, positive and negative values different colours.
# That's sometimes also useful if you want to distinguish points above or below the mean.
# Another option is scale_colour_viridis() provided by the viridis package.
# It's a continuous analog of the categorical ColorBrewer scales. 
# It has good perceptual properties eg:

df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

library(hexbin)
library(viridis)

ggplot(df, aes(x,y))+
  geom_hex()+
  coord_fixed()

ggplot(df, aes(x, y)) +
  geom_hex() +
  viridis::scale_fill_viridis() +
  coord_fixed()



# Note that all colour scales come in two variety: 
# scale_colour_x() and scale_fill_x() for the colour and fill aesthetics respectively

ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_colour_gradient(low = "white", high = "red") +
  coord_fixed()
# geom_hex() uses 'fill'not 'colour'and that's why the above code doesn't work.

ggplot(diamonds, aes(carat, price)) +
  geom_point(aes(colour = cut), alpha = 1/20)+
  guides(colour = guide_legend(nrow = 5, override.aes = list(alpha = 1)))

## read on zooming, themes and saving plots. 
