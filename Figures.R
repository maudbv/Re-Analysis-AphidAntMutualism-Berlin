# Figures for article


# Figure Aphid density with Sealing
# Interaction plot of partial residuals:
library(interactions)

interactions::interact_plot(Aph,
                            pred = date_s, 
                            modx = Seal_500_s,
                            legend.main = "% Sealing",
                            plot.points = TRUE , 
                            interval = TRUE, 
                            robust = TRUE,
                            int.type = "confidence",
                            x.label = "Date (standardized)",
                            y.label = "Aphid density (nb./mm)",
                            colors = "blue",
                            point.size = 1,
                            line.thickness = 0.8,
                            partial.residuals = FALSE,
                            facet.modx = TRUE,
                            modx.labels = c("- 1SD (= 7%)",
                                            "Mean %Sealing (= 25%)",
                                            "+ 1SD (= 42%)")
)

# Check out the sealing values for legend:
paste(c(round(mean(Aphid_density$Seal_500)-
                        sd(Aphid_density$Seal_500)),
                round(mean(Aphid_density$Seal_500)),
                round(mean(Aphid_density$Seal_500)+
                        sd(Aphid_density$Seal_500))),
      "%", sep = "")


# VISUALIZE ANT AGGRESSIVITY #####

#Prepare data:
#-->proportion of aggressive reacting ants
a<-Ant_aggressivity
a$ant<-1
plotAggressivity <- summaryBy(formula = reaction + ant ~ Seal_500 +
                              plot.simple + context,
                            data=a,
                            FUN=sum)

# calculate proportion of aggressive reactions
plotAggressivity$prop_reaction <-
  plotAggressivity$reaction.sum / plotAggressivity$ant.sum

# order by sealing
plotAggressivity <- plotAggressivity[
  order(plotAggressivity$Seal_500, plotAggressivity$context),]

# Extract predicted proportions from the fitted binomial model:
newd <- data.frame(
  unique(Ant_aggressivity[, c("Seal_500_s","Seal_500","context",
                              "date", "date_s","N_aphid_s")]),
  plantPop = NA,
  date = NA)


# Extract predicted proportions from the fitted binomial model:

reaction.binom<-glmmTMB(reaction ~ context + date_s + N_aphid_s + Seal_500_s +
                          context:date_s + context:N_aphid_s + context:Seal_500_s +
                          date_s:N_aphid_s + date_s:Seal_500_s +
                          N_aphid_s:Seal_500_s +
                          (1|plantPop/date),
                        family = binomial,
                        data=Ant_aggressivity)
newd <- data.frame(
  unique(Ant_aggressivity[, c("Seal_500_s","Seal_500","context",
                              "date", "date_s","N_aphid_s")]),
  plant = NA,
  plot.simple = NA,
  plantPop = NA,
  date = NA)

newd$predicted <- predict(reaction.binom,
                          newdata=newd,
                          type = "response",re.form = NA)
# base R plotting:
plot( predicted ~ Seal_500, data = newd,
      col = as.factor(newd$context),
      pch = 20, las = 1,
      ylab = "Probability of aggressive reaction",
      xlab = "% Sealing")

# ggplot with binomial regression line:
ggplot(data = newd, mapping = aes(Seal_500, predicted, colour = context)) +
  geom_point() +
  geom_smooth(method = "glm", formula = y ~ x,
              method.args=list(family="binomial"), se = FALSE) +
  xlab("% Sealing") +
  ylab("Probability of aggressive reaction")
