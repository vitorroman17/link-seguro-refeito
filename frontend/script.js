/* ========= i18n ========= */
const I18N = {
  pt: {
    title: "Link Seguro",
    subtitle: "Verifique links de compras e possíveis golpes",
    validate: "Validar Link",
    hint:
      "Dica: o endereço deve começar com <code>http://</code> ou <code>https://</code>.",
    // Protect CTA
    protect_cta_safe: "🛡️ Veja como se proteger",
    protect_cta_warn: "⚠️ Dicas urgentes: proteja-se",
    protect_cta_danger: "🚨 Atenção! Veja como se proteger agora",
    protect_title: "Como se proteger",
    tip_shop_title: "Compras on-line",
    tip_link_title: "Links recebidos (e-mail/WhatsApp)",
    tip_scam_title: "Se achar que caiu em golpe",
    admin_title: "Painel Administrativo",
    admin_inst: "Instituições ativas",
    admin_block: "Links bloqueados/mês",
    admin_users: "Usuários capacitados",
    tips: {
      shop: [
        "Pague sempre dentro da plataforma (ex.: Mercado Livre). Evite PIX/transferência enviados por chat.",
        "Prefira cartão de crédito (tem proteção contra fraudes). Desconfie de descontos exagerados.",
        "Verifique o endereço do site (domínio legítimo, sem erros), cadeado e <em>https</em>.",
        "Consulte a reputação/CNPJ e procure avaliações recentes.",
        "Desconfie de pressão por “pagar agora”."
      ],
      links: [
        "Desconfie de links recebidos por e-mail/WhatsApp/DM. Não clique em encurtadores sem pré-visualizar.",
        "Confirme o remetente digitando o endereço do site no navegador (não responda pelo link).",
        "Ative verificação em duas etapas (2FA) nas contas importantes.",
        "Nunca envie senhas, códigos ou dados de cartão por chat.",
        "Mantenha navegador e celular atualizados."
      ],
      scam: [
        "Interrompa pagamentos (estorne/cancele). Contate o banco imediatamente.",
        "Troque as senhas e deslogue sessões.",
        "Registre BO e acione o Procon/Plataforma para disputa.",
        "Guarde mensagens, comprovantes e prints como prova."
      ]
    },
    ui_result: {
      ok: { pill: "SEGURO", msg: "Este link não mostra sinais de atividade mal-intencionada. No entanto, permaneça vigilante enquanto navega." },
      unknown: { pill: "DESCONHECIDO", msg: "Não foi possível confirmar com certeza." },
      suspicious: { pill: "SUSPEITO", msg: "Cuidado. Pode ser arriscado." },
      dangerous: { pill: "PERIGOSO", msg: "Não recomendamos abrir este link." }
    }
  },
  en: {
    title: "Safe Link",
    subtitle: "Check shopping links and possible scams",
    validate: "Check Link",
    hint:
      "Tip: the address must start with <code>http://</code> or <code>https://</code>.",
    protect_cta_safe: "🛡️ See how to stay safe",
    protect_cta_warn: "⚠️ Urgent tips: protect yourself",
    protect_cta_danger: "🚨 Warning! Read safety tips now",
    protect_title: "How to stay safe",
    tip_shop_title: "Online shopping",
    tip_link_title: "Links you receive (email/WhatsApp)",
    tip_scam_title: "If you suspect fraud",
    admin_title: "Admin Panel",
    admin_inst: "Active institutions",
    admin_block: "Blocked links / month",
    admin_users: "Trained users",
    tips: {
      shop: [
        "Pay inside the marketplace/app. Avoid direct bank transfers from chat.",
        "Prefer credit card (fraud protection). Beware of unreal discounts.",
        "Check the domain, padlock and <em>https</em>.",
        "Search for reviews and official company data.",
        "Beware of urgency pressure to pay now."
      ],
      links: [
        "Be cautious with links via email/WhatsApp/DM. Avoid shortened URLs.",
        "Confirm sender by typing the website directly.",
        "Enable two-factor authentication (2FA).",
        "Never share passwords, codes or card data in chat.",
        "Keep your browser and phone updated."
      ],
      scam: [
        "Stop payments and contact your bank.",
        "Change passwords and sign out other sessions.",
        "File a police report and open a dispute with the platform.",
        "Keep proofs: messages, screenshots, receipts."
      ]
    },
    ui_result: {
      ok: { pill: "SAFE", msg: "This link seems safe." },
      unknown: { pill: "UNKNOWN", msg: "We couldn't confirm for sure." },
      suspicious: { pill: "SUSPICIOUS", msg: "Be careful. It may be risky." },
      dangerous: { pill: "DANGEROUS", msg: "We do not recommend opening this link." }
    }
  },
  es: {
    title: "Enlace Seguro",
    subtitle: "Verifique enlaces de compras y posibles estafas",
    validate: "Validar Enlace",
    hint:
      "Sugerencia: la dirección debe empezar con <code>http://</code> o <code>https://</code>.",
    protect_cta_safe: "🛡️ Cómo protegerse",
    protect_cta_warn: "⚠️ Consejos urgentes: protégete",
    protect_cta_danger: "🚨 ¡Atención! Lee cómo protegerte",
    protect_title: "Cómo protegerse",
    tip_shop_title: "Compras en línea",
    tip_link_title: "Enlaces recibidos (correo/WhatsApp)",
    tip_scam_title: "Si crees que caíste en una estafa",
    admin_title: "Panel Administrativo",
    admin_inst: "Instituciones activas",
    admin_block: "Enlaces bloqueados/mes",
    admin_users: "Usuarios capacitados",
    tips: {
      shop: [
        "Paga dentro de la plataforma. Evita transferencias directas por chat.",
        "Prefiere tarjeta de crédito. Desconfía de descuentos irreales.",
        "Confirma el dominio, candado y <em>https</em>.",
        "Busca reputación/CIF y reseñas recientes.",
        "Cuidado con la prisa por pagar ya."
      ],
      links: [
        "Desconfía de enlaces por correo/WhatsApp/DM. Evita acortadores.",
        "Confirma el remitente escribiendo la web directamente.",
        "Activa el doble factor (2FA).",
        "No compartas contraseñas, códigos ni datos de tarjeta.",
        "Mantén navegador y móvil actualizados."
      ],
      scam: [
        "Detén pagos y contacta tu banco.",
        "Cambia contraseñas y cierra sesiones.",
        "Denuncia y abre disputa con la plataforma.",
        "Guarda pruebas: mensajes, capturas, recibos."
      ]
    },
    ui_result: {
      ok: { pill: "SEGURO", msg: "Este enlace parece seguro." },
      unknown: { pill: "DESCONOCIDO", msg: "No pudimos confirmar con certeza." },
      suspicious: { pill: "SOSPECHOSO", msg: "Cuidado. Puede ser arriesgado." },
      dangerous: { pill: "PELIGROSO", msg: "No recomendamos abrir este enlace." }
    }
  },
  fr: {
    title: "Lien Sûr",
    subtitle: "Vérifiez les liens d’achat et les arnaques possibles",
    validate: "Vérifier le lien",
    hint:
      "Astuce : l’adresse doit commencer par <code>http://</code> ou <code>https://</code>.",
    protect_cta_safe: "🛡️ Comment se protéger",
    protect_cta_warn: "⚠️ Conseils urgents : protégez-vous",
    protect_cta_danger: "🚨 Attention ! Lisez comment vous protéger",
    protect_title: "Comment se protéger",
    tip_shop_title: "Achats en ligne",
    tip_link_title: "Liens reçus (e-mail/WhatsApp)",
    tip_scam_title: "Si vous pensez être victime d’une arnaque",
    admin_title: "Tableau de bord",
    admin_inst: "Institutions actives",
    admin_block: "Liens bloqués / mois",
    admin_users: "Utilisateurs formés",
    tips: {
      shop: [
        "Payez dans la plateforme. Évitez les virements directs via chat.",
        "Préférez la carte de crédit. Méfiez-vous des remises irréalistes.",
        "Vérifiez le domaine, le cadenas et le <em>https</em>.",
        "Cherchez les avis et les informations légales.",
        "Méfiez-vous de l’urgence à payer tout de suite."
      ],
      links: [
        "Soyez prudent avec les liens par e-mail/WhatsApp/DM. Évitez les URL raccourcies.",
        "Confirmez l’expéditeur en tapant le site directement.",
        "Activez l’authentification à deux facteurs (2FA).",
        "Ne partagez jamais mots de passe, codes ou données de carte.",
        "Maintenez navigateur et téléphone à jour."
      ],
      scam: [
        "Arrêtez les paiements et contactez votre banque.",
        "Changez vos mots de passe et fermez les sessions.",
        "Déposez plainte et ouvrez un litige sur la plateforme.",
        "Conservez les preuves : messages, captures, reçus."
      ]
    },
    ui_result: {
      ok: { pill: "SÛR", msg: "Ce lien semble sûr." },
      unknown: { pill: "INCONNU", msg: "Impossible de confirmer avec certitude." },
      suspicious: { pill: "SUSPECT", msg: "Attention. Cela peut être risqué." },
      dangerous: { pill: "DANGEREUX", msg: "Nous déconseillons d’ouvrir ce lien." }
    }
  }
};

let currentLang = "pt";

/* ========= helpers ========= */
const $ = (sel) => document.querySelector(sel);
const setHTML = (el, html) => (el.innerHTML = html);
const t = (key) => {
  const parts = key.split(".");
  let ref = I18N[currentLang];
  for (const p of parts) ref = ref?.[p];
  return ref ?? key;
};

/* ========= render i18n ========= */
function applyLang(lang = "pt") {
  currentLang = lang;
  document.documentElement.lang =
    lang === "pt" ? "pt-BR" : lang === "en" ? "en" : lang;

  // textos simples
  document.querySelectorAll("[data-i18n]").forEach((node) => {
    const key = node.getAttribute("data-i18n");
    setHTML(node, t(key));
  });

  // listas de dicas
  fillList("#tip_shop_list", t("tips.shop"));
  fillList("#tip_link_list", t("tips.links"));
  fillList("#tip_scam_list", t("tips.scam"));

  // atualiza CTA de acordo com último veredito (se houver)
  updateProtectionCTA(lastDecision ?? "unknown");
}
function fillList(sel, items) {
  const ul = $(sel);
  if (!ul) return;
  ul.innerHTML = "";
  (items || []).forEach((txt) => {
    const li = document.createElement("li");
    li.innerHTML = txt;
    ul.appendChild(li);
  });
}

/* ========= validação ========= */
const API_BASE =
  location.hostname === "localhost" || location.hostname === "127.0.0.1"
    ? "http://127.0.0.1:8000"
    : "https://api.vitorroman.com.br";

const form = $("#linkForm");
const input = $("#linkInput");
const resBox = $("#resultado");

let lastDecision = null;

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const url = input.value.trim();
  if (!url) return;

  renderResult("loading");
  try {
    const r = await fetch(`${API_BASE}/validar_link`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url })
    });
    const data = await r.json();

    lastDecision = normalizeDecision(data?.decision);
    renderResult(lastDecision);
    updateProtectionCTA(lastDecision);
  } catch {
    lastDecision = "unknown";
    renderResult("unknown");
    updateProtectionCTA("unknown");
  }
});

function normalizeDecision(d) {
  if (!d) return "unknown";
  const s = String(d).toLowerCase();
  if (["danger", "perigoso", "dangerous"].includes(s)) return "dangerous";
  if (["sus", "suspicious", "suspeito"].includes(s)) return "suspicious";
  if (["ok", "safe", "seguro"].includes(s)) return "ok";
  return "unknown";
}

function renderResult(kind) {
  if (kind === "loading") {
    resBox.innerHTML = `<span class="pill-status pill-warn">...</span>`;
    return;
  }
  const map = t(`ui_result.${kind}`);
  const pillClass =
    kind === "ok" ? "pill-ok" : kind === "dangerous" ? "pill-bad" : "pill-warn";

  resBox.innerHTML = `
    <span class="pill-status ${pillClass}">${map.pill}</span>
    <div class="result-msg">${map.msg}</div>
  `;
}

/* ========= proteção: CTA + abertura automática ========= */
const btnProtecao = $("#btnProtecao");
const boxProtecao = $("#boxProtecao");

btnProtecao.addEventListener("click", () => {
  const open = boxProtecao.classList.contains("hidden");
  setProtectOpen(open);
});

function setProtectOpen(open) {
  boxProtecao.classList.toggle("hidden", !open);
  btnProtecao.setAttribute("aria-expanded", String(open));
}

function updateProtectionCTA(decision) {
  btnProtecao.classList.remove("is-bad", "is-warn");

  if (decision === "dangerous") {
    btnProtecao.classList.add("is-bad");
    btnProtecao.innerText = t("protect_cta_danger");
    setProtectOpen(true); // abre automaticamente
  } else if (decision === "suspicious" || decision === "unknown") {
    btnProtecao.classList.add("is-warn");
    btnProtecao.innerText = t("protect_cta_warn");
    setProtectOpen(false);
  } else {
    btnProtecao.innerText = t("protect_cta_safe");
    setProtectOpen(false);
  }
}

/* ========= troca de idioma ========= */
document.querySelectorAll(".lang-switch [data-lang]").forEach((b) => {
  b.addEventListener("click", () => applyLang(b.dataset.lang));
});

// inicial
applyLang("pt");
