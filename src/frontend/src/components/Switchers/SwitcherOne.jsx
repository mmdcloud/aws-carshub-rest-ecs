import { useState } from "react";

const SwitcherOne = ({meta,value,onChange}) => {
  const [enabled, setEnabled] = useState(value);

  return (
    <div>
      <label
        htmlFor={meta}
        className="flex cursor-pointer select-none items-center"
      >
        <div className="relative">
          <input
            type="checkbox"
            id={meta}
            className="sr-only"            
            onChange={() => {
              onChange(!enabled);
              setEnabled(!enabled);
            }}
          />
          <div className="block h-8 w-14 rounded-full bg-meta-9 dark:bg-[#5A616B]"></div>
          <div
            className={`absolute left-1 top-1 h-6 w-6 rounded-full bg-white transition ${
              enabled && "!right-1 !translate-x-full !bg-primary dark:!bg-white"
            }`}
          ></div>
        </div>
      </label>
    </div>
  );
};

export default SwitcherOne;
