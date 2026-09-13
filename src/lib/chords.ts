// oxlint-disable anti-slop/no-known-value-widening
export type ChordSet = Record<string, string[]>;

// key of C (2 octaves: 3 & 4)
export const CHORDS: ChordSet = {
  "1": ["C3", "E3", "G3"],
  "2": ["D3", "F3", "A3"],
  "3": ["E3", "G3", "B3"],
  "4": ["F3", "A3", "C4"],
  "5": ["G3", "B3", "D4"],
  "6": ["A3", "C4", "E4"],
  "7": ["B3", "D4", "F4"],
};

export const CHORDS_RIGHT: ChordSet = {
  "1": ["C3", "E3", "G3", "B3"],
  "2": ["D3", "F3", "A3", "C4"],
  "3": ["E3", "G3", "B3", "D4"],
  "4": ["F3", "A3", "C4", "E4"],
  "5": ["G3", "B3", "D4", "F4"],
  "6": ["A3", "C4", "E4", "G4"],
  "7": ["B3", "D4", "F4", "A4"],
};

export const CHORDS_TOP_RIGHT: ChordSet = {
  "1": ["C3", "E3", "G3", "A#3"],
  "2": ["D3", "F#3", "A3", "C4"],
  "3": ["E3", "G#3", "B3", "D4"],
  "4": ["F3", "A3", "C4", "D#4"],
  "5": ["G3", "B3", "D4", "F4"],
  "6": ["A3", "C#4", "E4", "G4"],
  "7": ["B3", "D#4", "F#4", "A4"],
};
