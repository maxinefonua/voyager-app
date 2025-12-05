enum Airline {
  delta("Delta Air Lines", "dl-dal"),
  japan("Japan Airlines", "jl-jal"),
  norwegian("Norwegian", "dy-noz"),
  southwest("Southwest Airlines", "wn-swa"),
  finnair("Finnair", "ay-fin"),
  airnz("Air New Zealand", "nz-anz"),
  hawaiian("Hawaiian Airlines", "ha-hal"),
  alaska("Alaska Airlines", "as-asa"),
  united("United Airlines", "ua-ual"),
  advanced("Advanced Air", "an-wsn"),
  aegean("Aegean Airlines", "a3-aee"),
  american("American Airlines", "aa-aal"),
  frontier("Frontier Airlines", "f9-fft"),
  spirit("Spirit Airlines", "nk-nks"),
  volaris("Volaris", "y4-voi"),
  zipair("Zipair", "zg-tzp"),
  aerlingus("Aer Lingus", "ei-ein"),
  aeromexico("Aeromexico", "am-amx"),
  aircanada("Air Canada", "ac-aca"),
  airchina("Air China", "ca-cca"),
  airfrance("Air France", "af-afr"),
  ana("All Nippon Airways", "nh-ana"),
  asiana("Asiana Airlines", "oz-aar"),
  emirates("Emirates", "ek-uae");

  final String displayText;
  final String pathVariable;
  const Airline(this.displayText, this.pathVariable);

  static Airline fromName(String name) {
    return Airline.values.firstWhere(
      (airline) => airline.name == name.toLowerCase(),
      orElse: () => throw Exception('Airline $name not yet implemented'),
    );
  }

  static List<Airline> sortedValues() {
    List<Airline> toSort = List.from(Airline.values);
    toSort.sort((a, b) => a.name.compareTo(b.name));
    return toSort;
  }
}
