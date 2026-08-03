export function ArchIllustration() {
  return (
    <svg
      aria-label="Stylized Marrakesh architecture and palm trees"
      role="img"
      viewBox="0 0 720 720"
      className="h-auto w-full"
      fill="none"
    >
      <defs>
        <linearGradient id="sky" x1="360" y1="55" x2="360" y2="690" gradientUnits="userSpaceOnUse">
          <stop stopColor="#F7D7A1" />
          <stop offset="0.55" stopColor="#E88B58" />
          <stop offset="1" stopColor="#9A3E26" />
        </linearGradient>
        <linearGradient id="building" x1="360" y1="190" x2="360" y2="610" gradientUnits="userSpaceOnUse">
          <stop stopColor="#C85A35" />
          <stop offset="1" stopColor="#7E2F20" />
        </linearGradient>
        <clipPath id="arch">
          <path d="M94 650V310C94 177 188 94 360 34C532 94 626 177 626 310V650H94Z" />
        </clipPath>
      </defs>
      <g clipPath="url(#arch)">
        <rect width="720" height="720" fill="url(#sky)" />
        <circle cx="540" cy="190" r="62" fill="#F8E8C7" opacity="0.72" />
        <path d="M0 560C150 490 220 515 335 550C440 582 536 542 720 478V720H0V560Z" fill="#733925" opacity="0.34" />
        <path d="M0 605C142 538 240 560 336 595C450 637 568 585 720 540V720H0V605Z" fill="#351F17" opacity="0.23" />
        <g fill="url(#building)" stroke="#F8E8C7" strokeWidth="8" strokeLinejoin="round">
          <path d="M296 611V238H424V611H296Z" />
          <path d="M315 238V188H405V238H315Z" />
          <path d="M332 188V154H388V188H332Z" />
          <path d="M347 154V123H373V154H347Z" />
          <path d="M358 123V94H362V123H358Z" />
          <path d="M112 611V470H296V611H112Z" />
          <path d="M424 611V430H616V611H424Z" />
        </g>
        <g stroke="#F8E8C7" strokeWidth="8">
          <path d="M326 292H394M326 347H394M326 402H394M326 457H394" />
          <path d="M345 272V490M375 272V490" />
          <path d="M150 520H258M468 490H575" />
        </g>
        <g fill="#F8E8C7">
          <path d="M337 611V535C337 505 383 505 383 535V611H337Z" />
          <path d="M154 611V553C154 526 200 526 200 553V611H154Z" />
          <path d="M498 611V535C498 505 544 505 544 535V611H498Z" />
        </g>
        <g stroke="#183B2C" strokeWidth="11" strokeLinecap="round" strokeLinejoin="round">
          <path d="M190 590V305" />
          <path d="M190 327C145 278 110 293 90 318C139 305 163 332 190 366" />
          <path d="M190 327C238 274 272 292 291 320C244 304 217 335 190 366" />
          <path d="M190 337C153 321 123 342 111 374C147 348 170 353 190 380" />
          <path d="M190 337C228 319 257 339 271 370C232 348 210 355 190 380" />
        </g>
      </g>
      <path
        d="M94 650V310C94 177 188 94 360 34C532 94 626 177 626 310V650H94Z"
        stroke="#183B2C"
        strokeWidth="14"
      />
    </svg>
  );
}
