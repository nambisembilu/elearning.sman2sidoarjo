import { cva } from "class-variance-authority";
import {
  AlertTriangle,
  CheckCircle2,
  ChevronDown,
  Loader2,
  Search,
  X,
} from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { cn } from "../lib/utils";

const buttonVariants = cva(
  "inline-flex h-9 items-center justify-center gap-2 rounded-lg px-3.5 text-sm font-medium transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow-sm hover:bg-primary/90 active:scale-[0.98]",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        outline:
          "border bg-background hover:bg-muted hover:border-ring/30",
        ghost: "hover:bg-muted",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
      },
      size: {
        default: "h-9 px-3.5",
        sm: "h-8 px-2.5 text-xs",
        icon: "h-9 w-9 px-0",
      },
    },
    defaultVariants: { variant: "default", size: "default" },
  },
);

export function Button({ className, variant, size, ...props }) {
  return (
    <button
      className={cn(buttonVariants({ variant, size }), className)}
      {...props}
    />
  );
}

export function Card({ className, ...props }) {
  return (
    <div
      className={cn(
        "rounded-xl border bg-card text-card-foreground shadow-soft",
        className,
      )}
      {...props}
    />
  );
}

export function CardHeader({ className, ...props }) {
  return <div className={cn("space-y-1.5 p-5", className)} {...props} />;
}

export function CardTitle({ className, ...props }) {
  return (
    <h3
      className={cn(
        "text-base font-semibold leading-none tracking-normal",
        className,
      )}
      {...props}
    />
  );
}

export function CardDescription({ className, ...props }) {
  return (
    <p className={cn("text-sm text-muted-foreground", className)} {...props} />
  );
}

export function CardContent({ className, ...props }) {
  return <div className={cn("p-5 pt-0", className)} {...props} />;
}

export function Input({ className, ...props }) {
  return (
    <input
      className={cn(
        "flex h-9 w-full rounded-lg border bg-white px-3 py-1 text-sm outline-none transition-colors placeholder:text-muted-foreground focus:ring-2 focus:ring-ring disabled:cursor-not-allowed disabled:opacity-50",
        className,
      )}
      {...props}
    />
  );
}

export function Textarea({ className, ...props }) {
  return (
    <textarea
      className={cn(
        "min-h-24 w-full rounded-lg border bg-white px-3 py-2 text-sm outline-none transition-colors placeholder:text-muted-foreground focus:ring-2 focus:ring-ring",
        className,
      )}
      {...props}
    />
  );
}

export function Select({ className, children, ...props }) {
  return (
    <div className="relative">
      <select
        className={cn(
          "h-9 w-full appearance-none rounded-lg border bg-white px-3 pr-9 text-sm outline-none focus:ring-2 focus:ring-ring",
          className,
        )}
        {...props}
      >
        {children}
      </select>
      <ChevronDown className="pointer-events-none absolute right-3 top-2.5 h-4 w-4 text-muted-foreground" />
    </div>
  );
}

export function SearchableSelect({
  value,
  onChange,
  options = [],
  placeholder = "Pilih...",
  allowEmpty = true,
  className,
}) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const containerRef = useRef(null);
  const inputRef = useRef(null);

  const strValue = value == null ? "" : String(value);
  const selected = options.find((opt) => String(opt.value) === strValue);
  const filtered = search
    ? options.filter((opt) =>
        opt.label.toLowerCase().includes(search.toLowerCase()),
      )
    : options;

  useEffect(() => {
    if (open && inputRef.current) inputRef.current.focus();
  }, [open]);

  useEffect(() => {
    const handle = (e) => {
      if (containerRef.current && !containerRef.current.contains(e.target)) {
        setOpen(false);
        setSearch("");
      }
    };
    document.addEventListener("mousedown", handle);
    return () => document.removeEventListener("mousedown", handle);
  }, []);

  return (
    <div ref={containerRef} className={cn("relative", className)}>
      <button
        type="button"
        className="flex h-9 w-full items-center justify-between rounded-lg border bg-white px-3 text-sm outline-none transition-colors hover:border-ring/50 focus:ring-2 focus:ring-ring"
        onClick={() => setOpen((prev) => !prev)}
      >
        <span
          className={cn(
            "truncate",
            selected ? "text-foreground" : "text-muted-foreground",
          )}
        >
          {selected ? selected.label : placeholder}
        </span>
        <ChevronDown
          className={cn(
            "ml-2 h-4 w-4 shrink-0 text-muted-foreground transition-transform duration-150",
            open && "rotate-180",
          )}
        />
      </button>

      {open && (
        <div className="absolute z-[60] mt-1 w-full min-w-[180px] overflow-hidden rounded-xl border bg-card shadow-lg">
          <div className="border-b p-2">
            <div className="relative">
              <Search className="absolute left-2.5 top-2 h-3.5 w-3.5 text-muted-foreground" />
              <input
                ref={inputRef}
                className="h-8 w-full rounded-md border bg-white pl-8 pr-3 text-sm outline-none focus:ring-2 focus:ring-ring"
                placeholder="Cari..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Escape") {
                    setOpen(false);
                    setSearch("");
                  }
                }}
              />
            </div>
          </div>
          <div className="max-h-52 overflow-y-auto app-scrollbar py-1">
            {allowEmpty && (
              <button
                type="button"
                className={cn(
                  "w-full px-3 py-2 text-left text-sm transition-colors hover:bg-muted",
                  !strValue && "bg-primary/10 font-medium text-primary",
                )}
                onClick={() => {
                  onChange("");
                  setOpen(false);
                  setSearch("");
                }}
              >
                {placeholder}
              </button>
            )}
            {filtered.length ? (
              filtered.map((opt) => (
                <button
                  key={opt.value}
                  type="button"
                  className={cn(
                    "w-full px-3 py-2 text-left text-sm transition-colors hover:bg-muted",
                    String(opt.value) === strValue &&
                      "bg-primary/10 font-medium text-primary",
                  )}
                  onClick={() => {
                    onChange(opt.value);
                    setOpen(false);
                    setSearch("");
                  }}
                >
                  {opt.label}
                </button>
              ))
            ) : (
              <div className="px-3 py-4 text-center text-sm text-muted-foreground">
                Tidak ditemukan
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export function Label({ className, ...props }) {
  return (
    <label
      className={cn(
        "text-sm font-medium leading-none text-foreground",
        className,
      )}
      {...props}
    />
  );
}

export function Badge({ className, tone = "default", ...props }) {
  const toneClass = {
    default: "border-transparent bg-primary/10 text-primary",
    muted: "border-transparent bg-muted text-muted-foreground",
    success: "border-transparent bg-emerald-50 text-emerald-700",
    warning: "border-transparent bg-amber-50 text-amber-700",
    danger: "border-transparent bg-red-50 text-red-700",
  }[tone];
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-md border px-2 py-0.5 text-xs font-medium",
        toneClass,
        className,
      )}
      {...props}
    />
  );
}

export function Dialog({ open, title, description, children, footer, onClose }) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/40 p-4 backdrop-blur-sm">
      <div className="max-h-[92vh] w-full max-w-3xl overflow-hidden rounded-xl border bg-card shadow-xl">
        <div className="flex items-start justify-between gap-4 border-b bg-muted/30 p-5">
          <div>
            <h2 className="text-lg font-semibold">{title}</h2>
            {description ? (
              <p className="mt-1 text-sm text-muted-foreground">{description}</p>
            ) : null}
          </div>
          <Button variant="ghost" size="icon" onClick={onClose} aria-label="Tutup">
            <X className="h-4 w-4" />
          </Button>
        </div>
        <div className="max-h-[68vh] overflow-y-auto p-5 app-scrollbar">
          {children}
        </div>
        {footer ? (
          <div className="flex justify-end gap-2 border-t bg-muted/20 p-4">
            {footer}
          </div>
        ) : null}
      </div>
    </div>
  );
}

export function Table({ columns, rows, empty = "Data belum tersedia" }) {
  return (
    <div className="overflow-x-auto rounded-xl border bg-card shadow-soft app-scrollbar">
      <table className="w-full min-w-[760px] border-collapse text-sm">
        <thead className="border-b bg-muted/50 text-left text-xs uppercase tracking-wide text-muted-foreground">
          <tr>
            {columns.map((column) => (
              <th key={column.key} className="px-4 py-3 font-semibold">
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.length ? (
            rows.map((row, index) => (
              <tr
                key={row.id || index}
                className={cn(
                  "border-t transition-colors hover:bg-primary/[0.03]",
                  index % 2 === 1 && "bg-muted/[0.08]",
                )}
              >
                {columns.map((column) => (
                  <td key={column.key} className="px-4 py-3 align-top">
                    {column.render
                      ? column.render(row, index)
                      : row[column.key] || "-"}
                  </td>
                ))}
              </tr>
            ))
          ) : (
            <tr>
              <td
                className="px-4 py-12 text-center text-muted-foreground"
                colSpan={columns.length}
              >
                {empty}
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

export function Tabs({ value, onValueChange, items }) {
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-1 rounded-xl border bg-muted/40 p-1">
        {items.map((item) => (
          <button
            key={item.value}
            className={cn(
              "rounded-lg px-4 py-2 text-sm font-medium transition-all",
              value === item.value
                ? "bg-card text-primary shadow-soft"
                : "text-muted-foreground hover:bg-card/60 hover:text-foreground",
            )}
            onClick={() => onValueChange(item.value)}
          >
            {item.label}
          </button>
        ))}
      </div>
      {items.find((item) => item.value === value)?.content}
    </div>
  );
}

export function Toast({ type = "success", message, onClose }) {
  if (!message) return null;
  const Icon = type === "error" ? AlertTriangle : CheckCircle2;
  return (
    <div className="fixed bottom-5 right-5 z-[60] flex max-w-md items-start gap-3 rounded-xl border bg-card p-4 shadow-lg">
      <Icon
        className={cn(
          "mt-0.5 h-5 w-5 shrink-0",
          type === "error" ? "text-red-500" : "text-emerald-500",
        )}
      />
      <div className="flex-1 text-sm">{message}</div>
      <button onClick={onClose} aria-label="Tutup" className="shrink-0">
        <X className="h-4 w-4 text-muted-foreground" />
      </button>
    </div>
  );
}

export function Pagination({
  page,
  totalPages,
  total,
  pageSize,
  onPageChange,
  onPageSizeChange,
}) {
  if (!total && total !== 0) return null;
  const start = total === 0 ? 0 : (page - 1) * pageSize + 1;
  const end = Math.min(page * pageSize, total);
  const safeTotal = Math.max(totalPages, 1);

  return (
    <div className="mt-3 flex flex-col gap-3 text-sm text-muted-foreground sm:flex-row sm:items-center sm:justify-between">
      <span className="shrink-0">
        {total === 0 ? "Tidak ada data" : `${start}–${end} dari ${total} data`}
      </span>
      <div className="flex flex-wrap items-center gap-2">
        <div className="flex items-center gap-1.5">
          <span className="shrink-0 text-xs">Per hal:</span>
          <select
            value={pageSize}
            onChange={(e) => onPageSizeChange(Number(e.target.value))}
            className="h-8 cursor-pointer rounded-lg border bg-white px-2 text-sm outline-none focus:ring-2 focus:ring-ring"
          >
            {[10, 25, 50, 100].map((n) => (
              <option key={n} value={n}>
                {n}
              </option>
            ))}
          </select>
        </div>
        <div className="flex items-center gap-1">
          <Button
            variant="outline"
            size="sm"
            disabled={page <= 1}
            onClick={() => onPageChange(1)}
            aria-label="Halaman pertama"
          >
            «
          </Button>
          <Button
            variant="outline"
            size="sm"
            disabled={page <= 1}
            onClick={() => onPageChange(page - 1)}
            aria-label="Sebelumnya"
          >
            ‹
          </Button>
          <span className="min-w-[72px] text-center text-sm font-medium text-foreground">
            {page} / {safeTotal}
          </span>
          <Button
            variant="outline"
            size="sm"
            disabled={page >= safeTotal}
            onClick={() => onPageChange(page + 1)}
            aria-label="Berikutnya"
          >
            ›
          </Button>
          <Button
            variant="outline"
            size="sm"
            disabled={page >= safeTotal}
            onClick={() => onPageChange(safeTotal)}
            aria-label="Halaman terakhir"
          >
            »
          </Button>
        </div>
      </div>
    </div>
  );
}

export function LoadingBlock({ label = "Memuat data" }) {
  return (
    <div className="flex min-h-48 items-center justify-center rounded-xl border bg-card text-sm text-muted-foreground">
      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
      {label}
    </div>
  );
}
