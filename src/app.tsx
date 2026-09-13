import { useEffect, useRef } from "react";
import { start, Synth } from "tone";

import { CHORDS } from "./lib/chords";

export const App = () => {
  const voicesRef = useRef<Synth[]>([]);

  useEffect(() => {
    voicesRef.current = [
      new Synth().toDestination(),
      new Synth().toDestination(),
      new Synth().toDestination(),
      new Synth().toDestination(),
    ];

    const handleKeyDown = (event: KeyboardEvent) => {
      const { repeat, key } = event;

      if (repeat) {
        return;
      }

      if (
        key === "1" ||
        key === "2" ||
        key === "3" ||
        key === "4" ||
        key === "5" ||
        key === "6" ||
        key === "7"
      ) {
        const chord = CHORDS[key];

        for (const [index, note] of chord.entries()) {
          voicesRef.current[index].triggerAttack(note);
        }
      }
    };

    const handleKeyUp = (event: KeyboardEvent) => {
      const { key } = event;

      if (
        key === "1" ||
        key === "2" ||
        key === "3" ||
        key === "4" ||
        key === "5" ||
        key === "6" ||
        key === "7"
      ) {
        const chord = CHORDS[key];

        for (const [index, _] of chord.entries()) {
          voicesRef.current[index].triggerRelease();
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
    <div className="flex h-dvh items-center justify-center">
      <button type="button" onClick={start}>
        hello world
      </button>
    </div>
  );
};
