import math

svg = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round">
  <!-- Hair and back of head -->
  <path d="M11 2 C 7 2, 4 5, 4 10 C 4 14, 5 18, 8 20" />
  
  <!-- Forehead to Nose -->
  <path d="M11 2 C 14 2, 14 5, 13 7 C 12.5 8, 14 9, 14 10 C 14 10.5, 13.5 11, 13 11.5" />
  
  <!-- Cup (tilted towards mouth) -->
  <path d="M13 11.5 L 18.5 9.5 L 16.5 16.5 L 12 15 Z" />
  
  <!-- Chin and Neck -->
  <path d="M12 15 C 11.5 16, 10 17, 10 20" />
  
  <!-- Hand holding cup -->
  <path d="M10 20 C 12 19, 14 18, 15 16" />
  
  <!-- Closed eye (blissful) -->
  <path d="M10 7.5 Q 11 8.5 12 7.5" />
</svg>"""

with open("entry/src/main/resources/base/media/ic_action_drink2.svg", "w") as f:
    f.write(svg)
