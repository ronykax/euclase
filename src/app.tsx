import { useEffect, useRef } from "react";
import { Synth } from "tone";

import {
  CHORDS,
  CHORDS_LEFT,
  CHORDS_RIGHT,
  CHORDS_TOP_RIGHT,
} from "./lib/chords";
import type { ChordSet } from "./lib/chords";
import { arrowKeys, numberKeys } from "./lib/keys";

type Direction = "left" | "right" | "topRight" | "yes";

const JOYSTICK_MAPPING: Record<Direction, ChordSet> = {
  left: CHORDS_LEFT,
  right: CHORDS_RIGHT,
  topRight: CHORDS_TOP_RIGHT,
  yes: CHORDS,
};

export const App = () => {
  const voicesRef = useRef<Synth[]>([]);
  const activeNumberKeysRef = useRef<string[]>([]);
  const chordsRef = useRef(CHORDS);

  useEffect(() => {
    // 4 voices
    voicesRef.current = Array.from({ length: 4 }, () =>
      new Synth({
        envelope: { release: 8, sustain: 1 },
        oscillator: { type: "sawtooth" },
        portamento: 0.025,
        volume: -20,
      }).toDestination()
    );

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.repeat) {
        return;
      }

      if (numberKeys.includes(event.key)) {
        // store if it's the first active key
        const isFirstKey = activeNumberKeysRef.current.length === 0;

        // push to list of active keys
        activeNumberKeysRef.current.push(event.key);
        const chord = chordsRef.current[event.key];

        // play chord
        for (const [index, note] of chord.entries()) {
          const voice = voicesRef.current[index];

          // if it's the first key, trigger attack
          if (isFirstKey) {
            voice.triggerAttack(note);
          } else {
            voice.setNote(note);
          }
        }
      }

      if (arrowKeys.includes(event.key)) {
        let direction: Direction = "yes";

        if (event.key === "ArrowRight") {
          direction = "right";
        } else if (event.key === "ArrowLeft") {
          direction = "left";
        }

        chordsRef.current = JOYSTICK_MAPPING[direction];

        // if number keys are already held
        if (activeNumberKeysRef.current.length !== 0) {
          // oxlint-disable-next-line typescript/no-non-null-assertion
          const lastActiveKey = activeNumberKeysRef.current.at(-1)!;
          const chord = JOYSTICK_MAPPING[direction][lastActiveKey];

          for (const [index, note] of chord.entries()) {
            const voice = voicesRef.current[index];

            if (index < 3) {
              voice.setNote(note);
            } else {
              voice.triggerAttack(note);
            }
          }
        }
      }
    };

    const handleKeyUp = (event: KeyboardEvent) => {
      if (numberKeys.includes(event.key)) {
        // remove from the list of active keys
        activeNumberKeysRef.current = activeNumberKeysRef.current.filter(
          (k) => k !== event.key
        );

        // get the last active key
        const lastActiveKey = activeNumberKeysRef.current.at(-1);

        // it might not exist if only one key was ever held
        if (lastActiveKey) {
          const chord = chordsRef.current[lastActiveKey];

          for (const [index, note] of chord.entries()) {
            voicesRef.current[index].setNote(note);
          }
        } else {
          // use the voices to play each note in the chord
          for (const voice of voicesRef.current) {
            voice.triggerRelease();
          }
        }
      }

      if (arrowKeys.includes(event.key)) {
        chordsRef.current = CHORDS;

        if (activeNumberKeysRef.current.length > 0) {
          // oxlint-disable-next-line typescript/no-non-null-assertion
          const lastActiveKey = activeNumberKeysRef.current.at(-1)!;
          const chord = CHORDS[lastActiveKey];

          for (const [index, note] of chord.entries()) {
            voicesRef.current[index].setNote(note);
          }

          voicesRef.current[3].triggerRelease();
        }
      }
    };

    window.addEventListener("keydown", handleKeyDown);
    window.addEventListener("keyup", handleKeyUp);

    return () => {
      window.removeEventListener("keydown", handleKeyDown);
      window.removeEventListener("keyup", handleKeyUp);

      for (const voice of voicesRef.current) {
        voice.dispose();
      }
    };
  }, []);

  return (
    <div className="flex h-dvh items-center justify-center text-4xl font-semibold select-none sm:text-6xl md:text-8xl">
      euclase
    </div>
  );
};
