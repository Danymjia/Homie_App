import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "npm:stripe@14.25.0";
import { createClient } from "jsr:@supabase/supabase-js";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2023-10-16",
});

const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

serve(async (req) => {
  const signature = req.headers.get("stripe-signature");
  const body = await req.text();

  let event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature!,
      Deno.env.get("STRIPE_WEBHOOK_SECRET")!,
    );
  } catch (err) {
    return new Response("Invalid signature", { status: 400 });
  }

  const subscription = event.data.object as Stripe.Subscription;

  const customerId = subscription.customer as string;
  const status = subscription.status;

  // Buscar usuario por stripe_customer_id
  const { data: profile } = await supabaseAdmin
    .from("profiles")
    .select("id")
    .eq("stripe_customer_id", customerId)
    .single();

  if (!profile) {
    return new Response("User not found", { status: 200 });
  }

  // Premium solo si status válido
  const isPremium = status === "trialing" || status === "active";

  await supabaseAdmin
    .from("profiles")
    .update({
      stripe_subscription_status: status,
      is_premium: isPremium,
      premium_until: subscription.current_period_end
        ? new Date(subscription.current_period_end * 1000)
        : null,
    })
    .eq("id", profile.id);

  return new Response("ok", { status: 200 });
});
