import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "jsr:@supabase/supabase-js";
import Stripe from "npm:stripe@14.25.0";

/* ---------------- CORS ---------------- */
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/* ---------------- STRIPE ---------------- */
const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
  httpClient: Stripe.createFetchHttpClient(),
});

const PRICES: Record<string, string> = {
  monthly: "price_1SrMmx1Zzf1hLpXtogDtqUpG",
  annual: "price_1SrMnN1Zzf1hLpXt5CvFvHVQ",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    /* -------- 1. Leer token -------- */
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Token no enviado" }),
        { status: 401, headers: corsHeaders },
      );
    }

    /* -------- 2. Cliente con JWT del usuario -------- */
    const supabaseUser = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      {
        global: {
          headers: { Authorization: authHeader },
        },
      },
    );

    const { data: { user }, error: authError } = await supabaseUser.auth
      .getUser();

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Usuario no autorizado" }),
        { status: 401, headers: corsHeaders },
      );
    }

    /* -------- 3. Leer plan -------- */
    const { plan } = await req.json();
    if (!plan || !PRICES[plan]) {
      return new Response(
        JSON.stringify({ error: "Plan inválido" }),
        { status: 400, headers: corsHeaders },
      );
    }

    /* -------- 4. Cliente Admin -------- */
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("stripe_customer_id")
      .eq("id", user.id)
      .single();

    let customerId = profile?.stripe_customer_id;

    if (!customerId) {
      const customer = await stripe.customers.create({
        email: user.email!,
        metadata: { supabase_user_id: user.id },
      });

      customerId = customer.id;

      await supabaseAdmin
        .from("profiles")
        .update({ stripe_customer_id: customerId })
        .eq("id", user.id);
    }

    /* -------- 5. Crear suscripción CON TRIAL -------- */
    const subscription = await stripe.subscriptions.create({
      customer: customerId,
      items: [{ price: PRICES[plan] }],
      trial_period_days: 7,
    });

    /* -------- 6. Activar premium -------- */
    await supabaseAdmin
      .from("profiles")
      .update({
        stripe_subscription_id: subscription.id,
      })
      .eq("id", user.id);

    return new Response(
      JSON.stringify({
        success: true,
        subscriptionStatus: subscription.status, // trialing
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  } catch (err: any) {
    console.error(err);
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: corsHeaders },
    );
  }
});
