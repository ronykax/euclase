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
      if (event.repeat) {
        return;
      }

      const chord = CHORDS[event.key];

      for (const [index, note] of chord.entries()) {
        voicesRef.current[index].triggerAttack(note);
      }
    };

    const handleKeyUp = (event: KeyboardEvent) => {
      const chord = CHORDS[event.key];

      for (const [index, _] of chord.entries()) {
        voicesRef.current[index].triggerRelease();
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
