/datum/morality
	var/name = ""
	var/desc = ""
	/// Humanity or Enlightenment
	var/alignment
	/// The bearing of the path's ethos
	var/bearing
	/// The current dot score of the path
	var/score = 7

/datum/morality/humanity
	name = "Humanity"
	desc = "Humanity is a measure of how closely a vampire clings to the morality and values of mortal life, and consequently how well they are able to resist the urges of the Beast."
	alignment = MORALITY_HUMANITY
	bearing = BEARING_MUNDANE

/datum/morality/power
	name = "Path of Power and the Inner Voice"
	desc = "The Path of Power and the Inner Voice is a Path of Enlightenment that controls the Beast through rigorous determination and the amassing of worldly power. Adherents are called Unifiers."
	alignment = MORALITY_ENLIGHTENMENT
	bearing = BEARING_COMMAND

/datum/morality/heaven
	name = "Path of Heaven"
	desc = "Followers of Via Caeli attempt to control their Beast through religious devotion. They are frequently referred to as Noddists or the Faithful."
	alignment = MORALITY_HUMANITY
	bearing = BEARING_HOLINESS

/datum/morality/metamorphosis
	name = "Path of Metamorphosis"
	desc = "The Path of Metamorphosis is a Path of Enlightenment that controls the Beast by studying its limits and the limits of vampirism in general. The Path is the result of the earlier Road of Metamorphosis and it is practiced mostly by the Tzimisce clan."
	alignment = MORALITY_ENLIGHTENMENT
	bearing = BEARING_INHUMANITY

/datum/morality/assamite
	name = "Path of Blood"
	desc = "The Path of Blood is a Path of Enlightenment common among the Assamites. Its followers fight the Beast with rigorous devotion to the cause of Haqim. Adherents are called Dervishes or Assassins."
	alignment = MORALITY_ENLIGHTENMENT
	bearing = BEARING_RESOLVE

/datum/morality/hive
	name = "Path of the Hive"
	desc = "Via Hyron, more commonly called Road of the Hive or Path of the Hive, is a minor Road that is followed almost exclusively by the Baali. Adherents are called Abelenes."
	alignment = MORALITY_ENLIGHTENMENT
	bearing = BEARING_JUSTICE

/datum/morality/kings
	name = "Road of Kings"
	desc = "Via Regalis, commonly called the Road of Kings. Followers of Via Regalis control their Beast by ruling over others. Mortals are inferior, promises will be fulfilled, and power is everything. Those who follow the Road of Kings are known as Scions."
	alignment = MORALITY_HUMANITY
	bearing = BEARING_COMMAND

/datum/morality/heart
	name = "Path of the Scorched Heart"
	desc = "The Path of the Scorched Heart, originally called the Path of Rathmonicus, is an ancient Path of Enlightenment that originates with the True Brujah. Based on the Book of the Empty Heart by Rathmonicus, it was first disseminated among a few Kindred in the Catholic Church; its scriptures were later reunited and compiled by the True Black Hand. The Path of the Scorched Heart controls the Beast by systematically eradicating every emotion within the vampire's heart. The Path is especially favored among the True Brujah, who already cultivate few emotions. Adherents are called the Unforgiving."
	alignment = MORALITY_ENLIGHTENMENT
	bearing = BEARING_INTELLECT

/datum/morality/typhon
	name = "Path of Typhon"
	desc = "The Path of Typhon is a Path of Enlightenment that draws heavily on Setite doctrine and the religion around their Antediluvian. Adherents are called Theophidians and Typhonists. Outsiders call them Corruptors."
	alignment = MORALITY_ENLIGHTENMENT
	bearing = BEARING_DEVOTION
