import { useEffect, useRef } from "react";
import { Synth } from "tone";

import { CHORDS } from "./lib/chords";
import { numberKeys } from "./lib/keys";

export const App = () => {
  const voicesRef = useRef<Synth[]>([]);
  const activeNumberKeysRef = useRef<string[]>([]);

  useEffect(() => {
    // 4 voices
    voicesRef.current = Array.from({ length: 4 }, () =>
      new Synth({
        envelope: { release: 8, sustain: 1 },
        oscillator: { type: "sawtooth" },
        portamento: 0.1,
        volume: -16,
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
        const chord = CHORDS[event.key];

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
          const chord = CHORDS[lastActiveKey];

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
    <div className="flex h-dvh items-center justify-center text-4xl font-semibold sm:text-6xl md:text-8xl">
      euclase
    </div>
  );
};
