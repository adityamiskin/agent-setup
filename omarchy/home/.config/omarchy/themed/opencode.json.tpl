{
  "$schema": "https://opencode.ai/theme.json",
  "base": {
    "categorical": ["accent", "purple", "green", "blue", "red"],
    "text": {
      "base": "$hue.neutral.200",
      "muted": "$hue.neutral.400",
      "action": {
        "primary": {
          "base": "{{ accent }}",
          "$disabled": "$hue.neutral.500",
          "$focused": "{{ accent }}",
          "$selected": "$hue.interactive.200"
        },
        "secondary": {
          "base": "$text.muted",
          "$hovered": "$text.base"
        },
        "destructive": {
          "base": "$hue.red.200",
          "$disabled": "$hue.neutral.500"
        }
      },
      "formfield": {
        "base": "$hue.neutral.200",
        "$hovered": "$hue.interactive.200",
        "$focused": "{{ accent }}",
        "$pressed": "$hue.interactive.200",
        "$disabled": "$hue.neutral.500",
        "$selected": "{{ selection }}"
      },
      "feedback": {
        "error": { "base": "$hue.red.200" },
        "warning": { "base": "$hue.yellow.200" },
        "success": { "base": "$hue.green.200" },
        "info": { "base": "$hue.cyan.200" }
      }
    },
    "background": {
      "base": "$hue.neutral.800",
      "raised": {
        "base": "$hue.neutral.700",
        "high": "$hue.neutral.600",
        "max": "$hue.neutral.500"
      },
      "action": {
        "primary": {
          "base": "transparent",
          "$hovered": "$background.raised.base",
          "$focused": "{{ accent }}",
          "$selected": "transparent"
        },
        "secondary": { "base": "transparent" },
        "destructive": { "base": "$hue.red.200" }
      },
      "formfield": { "base": "$background.base" },
      "feedback": {
        "error": { "base": "$background.base" },
        "warning": { "base": "$background.base" },
        "success": { "base": "$background.base" },
        "info": { "base": "$background.base" }
      }
    },
    "border": { "base": "{{ mix background foreground 30% }}" },
    "scrollbar": { "base": "{{ mix background foreground 42% }}" },
    "diff": {
      "text": {
        "added": "$hue.green.300",
        "removed": "$hue.red.300",
        "context": "$hue.neutral.300",
        "hunkHeader": "$hue.neutral.400"
      },
      "background": {
        "added": "$hue.green.800",
        "removed": "$hue.red.800",
        "context": "$hue.neutral.700"
      },
      "highlight": {
        "added": "$hue.green.200",
        "removed": "$hue.red.200"
      },
      "lineNumber": {
        "text": "$hue.neutral.400",
        "background": {
          "added": "$hue.green.900",
          "removed": "$hue.red.900"
        }
      }
    },
    "syntax": {
      "comment": "$hue.neutral.400",
      "keyword": "{{ magenta }}",
      "function": "$hue.blue.200",
      "variable": "$hue.red.200",
      "string": "$hue.green.200",
      "number": "$hue.orange.200",
      "type": "$hue.yellow.200",
      "operator": "$hue.cyan.200",
      "punctuation": "$hue.neutral.200"
    },
    "markdown": {
      "text": "$hue.neutral.200",
      "heading": "{{ accent }}",
      "link": "$hue.blue.200",
      "linkText": "$hue.cyan.200",
      "code": "$hue.green.200",
      "blockQuote": "$hue.yellow.200",
      "emphasis": "$hue.yellow.200",
      "strong": "$hue.orange.200",
      "horizontalRule": "$hue.neutral.400",
      "listItem": "$hue.blue.200",
      "listEnumeration": "$hue.cyan.200",
      "image": "$hue.blue.200",
      "imageText": "$hue.cyan.200",
      "codeBlock": "$hue.neutral.200"
    },
    "@dialog": {
      "background": {
        "base": "$background.raised.base",
        "action": {
          "primary": {
            "$hovered": "$background.raised.high"
          }
        }
      }
    }
  },
  "{{ mode }}": {
    "hue": {
      "gray": {
        "100": "{{ mix foreground light_foreground 60% }}",
        "200": "{{ foreground }}",
        "300": "{{ mix foreground background 28% }}",
        "400": "{{ mix foreground background 55% }}",
        "500": "{{ mix foreground background 70% }}",
        "600": "{{ mix background foreground 24% }}",
        "700": "{{ lighter_background }}",
        "800": "{{ background }}",
        "900": "{{ mix background foreground 2% }}"
      },
      "red": {
        "100": "{{ mix red foreground 55% }}",
        "200": "{{ mix red foreground 25% }}",
        "300": "{{ mix red foreground 8% }}",
        "400": "{{ red }}",
        "500": "{{ mix red background 12% }}",
        "600": "{{ mix red background 32% }}",
        "700": "{{ mix red background 52% }}",
        "800": "{{ mix red background 70% }}",
        "900": "{{ mix red background 84% }}"
      },
      "orange": {
        "100": "{{ mix orange foreground 55% }}",
        "200": "{{ mix orange foreground 25% }}",
        "300": "{{ mix orange foreground 8% }}",
        "400": "{{ orange }}",
        "500": "{{ mix orange background 12% }}",
        "600": "{{ mix orange background 32% }}",
        "700": "{{ mix orange background 52% }}",
        "800": "{{ mix orange background 70% }}",
        "900": "{{ mix orange background 84% }}"
      },
      "yellow": {
        "100": "{{ mix yellow foreground 55% }}",
        "200": "{{ mix yellow foreground 25% }}",
        "300": "{{ mix yellow foreground 8% }}",
        "400": "{{ yellow }}",
        "500": "{{ mix yellow background 12% }}",
        "600": "{{ mix yellow background 32% }}",
        "700": "{{ mix yellow background 52% }}",
        "800": "{{ mix yellow background 70% }}",
        "900": "{{ mix yellow background 84% }}"
      },
      "green": {
        "100": "{{ mix green foreground 55% }}",
        "200": "{{ mix green foreground 25% }}",
        "300": "{{ mix green foreground 8% }}",
        "400": "{{ green }}",
        "500": "{{ mix green background 12% }}",
        "600": "{{ mix green background 32% }}",
        "700": "{{ mix green background 52% }}",
        "800": "{{ mix green background 70% }}",
        "900": "{{ mix green background 84% }}"
      },
      "cyan": {
        "100": "{{ mix cyan foreground 55% }}",
        "200": "{{ mix cyan foreground 25% }}",
        "300": "{{ mix cyan foreground 8% }}",
        "400": "{{ cyan }}",
        "500": "{{ mix cyan background 12% }}",
        "600": "{{ mix cyan background 32% }}",
        "700": "{{ mix cyan background 52% }}",
        "800": "{{ mix cyan background 70% }}",
        "900": "{{ mix cyan background 84% }}"
      },
      "blue": {
        "100": "{{ mix blue foreground 55% }}",
        "200": "{{ mix blue foreground 25% }}",
        "300": "{{ mix blue foreground 8% }}",
        "400": "{{ blue }}",
        "500": "{{ mix blue background 12% }}",
        "600": "{{ mix blue background 32% }}",
        "700": "{{ mix blue background 52% }}",
        "800": "{{ mix blue background 70% }}",
        "900": "{{ mix blue background 84% }}"
      },
      "purple": {
        "100": "{{ mix magenta foreground 55% }}",
        "200": "{{ mix magenta foreground 25% }}",
        "300": "{{ mix magenta foreground 8% }}",
        "400": "{{ magenta }}",
        "500": "{{ mix magenta background 12% }}",
        "600": "{{ mix magenta background 32% }}",
        "700": "{{ mix magenta background 52% }}",
        "800": "{{ mix magenta background 70% }}",
        "900": "{{ mix magenta background 84% }}"
      },
      "accent": "$hue.orange",
      "interactive": "$hue.blue",
      "neutral": "$hue.gray"
    }
  }
}
