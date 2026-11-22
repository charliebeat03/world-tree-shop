import { useEffect, useMemo, useState } from 'react'
import { Search, ShoppingBag, Plus, Minus, X, TreePine, ArrowRight, ShieldCheck, MapPin, Clock3, RefreshCw, Gift } from 'lucide-react'
import { supabase, supabaseConfigured } from './lib_supabase'

type Tariff = 'Zelle'|'IBAN'|'Bizum'|'Posta'|'Reales'|'MXN'|'PDO'|'Rublos'|'Guyana'|'Western'
type Category = { id:string; name:string }
type PriceRow = { pricing_option_id:string; amount:number|string; pricing_options:{code:Tariff;display_name:string}|null }
type ProductRow = { id:string; name:string; description:string|null; image_main?:string|null; status:'available'|'check_availability'|'sold_out'|'hidden'; categories:Category|null; product_prices:PriceRow[]; product_images:{storage_path:string;alt_text:string;sort_order:number}[] }
type ComboProduct = { id:string; name:string; description:string|null; image_main?:string|null; status:'available'|'check_availability'|'sold_out'|'hidden'; product_images:{storage_path:string;alt_text:string;sort_order:number}[] }
type ComboRow = { id:string; name:string; description:string; status:'available'|'sold_out'|'hidden'; combo_prices:{amount:number|string;pricing_options:{code:Tariff;display_name:string}|null}[]; combo_images:{storage_path:string;alt_text:string;sort_order?:number}[]; combo_items:{quantity:number;sort_order?:number;products:ComboProduct|null}[] }
type Zone = { id:string; name:string; is_enabled:boolean; provinces:{name:string}|null }
type CartLine = { id:string; name:string; kind:'product'|'combo'; quantity:number; price?:number; status:string }

const tariffs:Tariff[]=['Zelle','IBAN','Bizum','Posta','Reales','MXN','PDO','Rublos','Guyana','Western']
const waNumber=import.meta.env.VITE_WHATSAPP_NUMBER||'5353526551'
const fallbackMunicipalities=['Santiago de Cuba','Contramaestre','Palma Soriano','San Luis','Songo-La Maya','Segundo Frente','Tercer Frente','Guamá','Mella']
const money=(n:number,t:Tariff)=>`${n.toLocaleString('es-ES',{minimumFractionDigits:2,maximumFractionDigits:2})} ${t}`
// Normaliza acentos y mayúsculas para que 'frijoles' encuentre 'fríjoles'.
const normalizeSearch=(value:string)=>value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLocaleLowerCase().trim()

export default function App(){
 const [tariff,setTariff]=useState<Tariff>(()=>{const saved=localStorage.getItem('worldtree-tariff');return tariffs.includes(saved as Tariff)?saved as Tariff:'Zelle'})
 const [categories,setCategories]=useState<Category[]>([])
 const [products,setProducts]=useState<ProductRow[]>([])
 const [combos,setCombos]=useState<ComboRow[]>([])
 const [selectedCombo,setSelectedCombo]=useState<ComboRow|null>(null)
 const [zones,setZones]=useState<Zone[]>([])
 const [loading,setLoading]=useState(true)
 const [loadError,setLoadError]=useState('')
 const [category,setCategory]=useState('Todos')
 const [query,setQuery]=useState('')
 const [cart,setCart]=useState<CartLine[]>([])
 const [showCart,setShowCart]=useState(false)
 const [buyer,setBuyer]=useState({name:'',phone:'',recipient:'',idCard:'',recipientPhone:'',municipality:'',address:'',notes:''})
 const [catalogMode,setCatalogMode]=useState<'products'|'combos'>('products')
  const [toast,setToast]=useState<{msg:string;ts:number}|null>(null)
  const [justAdded,setJustAdded]=useState<string|null>(null)

  // Keep the page behind the cart from scrolling while the cart drawer is open.
  useEffect(()=>{
   if(!showCart)return
   const previousOverflow=document.body.style.overflow
   const previousPaddingRight=document.body.style.paddingRight
   const scrollbarWidth=window.innerWidth-document.documentElement.clientWidth
   document.body.style.overflow='hidden'
   if(scrollbarWidth>0)document.body.style.paddingRight=`${scrollbarWidth}px`
   const onKeyDown=(event:KeyboardEvent)=>{if(event.key==='Escape')setShowCart(false)}
   window.addEventListener('keydown',onKeyDown)
   return()=>{
    document.body.style.overflow=previousOverflow
    document.body.style.paddingRight=previousPaddingRight
    window.removeEventListener('keydown',onKeyDown)
   }
  },[showCart])

  useEffect(()=>{localStorage.setItem('worldtree-tariff',tariff)},[tariff])
 useEffect(()=>{
  let active=true
  async function load(){
   setLoading(true);setLoadError('')
   if(!supabaseConfigured||!supabase){setProducts([]);setCombos([]);setCategories([]);setZones([]);setLoadError('La tienda todavía no está conectada a su base de datos.');setLoading(false);return}
   const [p,c,b,z]=await Promise.all([
    supabase.from('products').select('id,name,description,image_main,status,categories(id,name),product_prices(amount,pricing_options(code,display_name)),product_images(storage_path,alt_text,sort_order)').neq('status','hidden').order('sort_order'),
    supabase.from('categories').select('id,name').eq('is_active',true).order('sort_order'),
    supabase.from('combos').select('id,name,description,status,combo_prices(amount,pricing_options(code,display_name)),combo_images(storage_path,alt_text),combo_items(quantity,sort_order,products(id,name,description,image_main,status,product_images(storage_path,alt_text,sort_order)))').neq('status','hidden').order('sort_order'),
    supabase.from('municipalities').select('id,name,is_enabled,provinces(name)').eq('is_enabled',true).order('sort_order')
   ])
   if(!active)return
   const err=p.error||c.error||b.error||z.error
   if(err)setLoadError(err.message)
   else{setProducts((p.data||[]) as unknown as ProductRow[]);setCategories(c.data||[]);setCombos((b.data||[]) as unknown as ComboRow[]);setZones((z.data||[]) as unknown as Zone[])}
   setLoading(false)
  }
  load()
  return()=>{active=false}
 },[])

 const selectedMunicipalities=zones.filter(z=>z.provinces?.name==='Santiago de Cuba').map(z=>z.name)
 // La búsqueda no distingue tildes, mayúsculas ni espacios sobrantes.
 const normalizedQuery=normalizeSearch(query)
 const visibleProducts=useMemo(()=>products.filter(p=>
   (category==='Todos'||p.categories?.name===category)&&
   (!normalizedQuery||[p.name,p.description||'',p.categories?.name||''].some(value=>normalizeSearch(value).includes(normalizedQuery)))
 ),[products,category,normalizedQuery])
 // En la pestaña de combos, buscar un producto devuelve los combos que lo contienen,
 // nunca una tarjeta individual del producto buscado.
 const visibleCombos=useMemo(()=>combos.filter(c=>
   !normalizedQuery||
   normalizeSearch(c.name).includes(normalizedQuery)||
   normalizeSearch(c.description||'').includes(normalizedQuery)||
   c.combo_items.some(item=>item.products&&(
     normalizeSearch(item.products.name).includes(normalizedQuery)||
     normalizeSearch(item.products.description||'').includes(normalizedQuery)
   ))
 ),[combos,normalizedQuery])
 const activeTariff=tariff
 const productPrice=(p:ProductRow)=>{const row=p.product_prices.find(x=>x.pricing_options?.code===activeTariff);return row?Number(row.amount):undefined}
 const comboPrice=(c:ComboRow)=>{const row=c.combo_prices.find(x=>x.pricing_options?.code===activeTariff);return row?Number(row.amount):undefined}
 const imageUrl=(path:string)=>/^https?:\/\//i.test(path)?path:(supabase?.storage.from('world-tree-products').getPublicUrl(path).data.publicUrl||'')
 const subtotal=cart.reduce((s,l)=>s+(l.price||0)*l.quantity,0)
 const missingPrice=cart.some(l=>l.price===undefined)
 const showToast=(msg:string)=>{setToast({msg,ts:Date.now()});setTimeout(()=>setToast(null),2200)}
const addLine=(line:CartLine)=>{if(line.status==='sold_out'||line.price===undefined)return;setJustAdded(`${line.kind}-${line.id}`);setTimeout(()=>setJustAdded(null),600);setCart(prev=>{const old=prev.find(x=>x.id===line.id&&x.kind===line.kind);return old?prev.map(x=>x.id===line.id&&x.kind===line.kind?{...x,quantity:x.quantity+1}:x):[...prev,line]});showToast('Añadido al carrito')}
 const changeQty=(id:string,kind:string,delta:number)=>setCart(prev=>prev.map(x=>x.id===id&&x.kind===kind?{...x,quantity:x.quantity+delta}:x).filter(x=>x.quantity>0))
 function sendOrder(){
  if(!buyer.name.trim()||!buyer.phone.trim()||!buyer.recipient.trim()||!buyer.idCard.trim()||!buyer.recipientPhone.trim()||!buyer.municipality||!buyer.address.trim()||!cart.length||missingPrice)return
  const lines=cart.map(l=>`• ${l.name} x${l.quantity} | ${money(l.price!,tariff)} c/u`).join('\n')
  const message=`🌳 *WORLD TREE | SOLICITUD DE PEDIDO*\n\n*Comprador:* ${buyer.name}\n*Teléfono comprador:* ${buyer.phone}\n\n*Destinatario en Cuba:* ${buyer.recipient}\n*Carnet de identidad:* ${buyer.idCard}\n*Teléfono destinatario:* ${buyer.recipientPhone}\n*Provincia:* Santiago de Cuba\n*Municipio:* ${buyer.municipality}\n*Dirección:* ${buyer.address}\n\n*Artículos:*\n${lines}\n\n*Modalidad de precio seleccionada:* ${tariff}\n*Subtotal estimado:* ${money(subtotal,tariff)}\n*Notas:* ${buyer.notes||'Ninguna'}\n\nSolicitud pendiente de confirmación personal de disponibilidad, importe final, entrega y pago.`
  window.open(`https://wa.me/${waNumber}?text=${encodeURIComponent(message)}`,'_blank','noopener,noreferrer')
 }
 const ProductCard=({p}:{p:ProductRow})=>{const price=productPrice(p),img=[...(p.product_images||[])].sort((a,b)=>a.sort_order-b.sort_order)[0],photoPath=img?.storage_path||p.image_main;return <article className="product-card"><div className="product-image">{photoPath?<img src={imageUrl(photoPath)} alt={img?.alt_text||p.name} onError={e=>{e.currentTarget.style.display='none';const fallback=e.currentTarget.parentElement?.querySelector('.image-placeholder');if(fallback)fallback.classList.remove('image-fallback-hidden')}}/>:null}<div className={`image-placeholder ${photoPath?'image-fallback-hidden':''}`}><TreePine size={40}/><span>WORLD TREE</span></div><span className={`status ${p.status==='sold_out'?'sold':p.status==='check_availability'?'check':''}`}>{p.status==='sold_out'?'Agotado':p.status==='check_availability'?'Consultar':'Disponible'}</span></div><div className="product-body"><small className="product-category">{p.categories?.name||'Otros'}</small><h3>{p.name}</h3>{p.description?.trim()&&<p>{p.description}</p>}<div className="product-bottom"><strong>{price===undefined?'Precio pendiente':money(price,tariff)}</strong><button className={justAdded===`product-${p.id}`?'added':''} disabled={p.status==='sold_out'||price===undefined} onClick={()=>addLine({id:p.id,name:p.name,kind:'product',quantity:1,price,status:p.status})} aria-label={`Añadir ${p.name}`}><Plus size={18}/></button></div>{price===undefined&&<small className="missing-price">Tarifa aún no registrada</small>}</div></article>}
 const ComboCard=({c}:{c:ComboRow})=>{const price=comboPrice(c),img=[...c.combo_images].sort((a,b)=>(a.sort_order||0)-(b.sort_order||0))[0],items=[...c.combo_items].sort((a,b)=>(a.sort_order||0)-(b.sort_order||0)),highlights=items.slice(0,4);return <article className="product-card combo-card"><button className="combo-image-open" onClick={()=>setSelectedCombo(c)} aria-label={`Ver contenido de ${c.name}`}><div className="product-image">{img?<img src={imageUrl(img.storage_path)} alt={img.alt_text||c.name} onError={e=>{e.currentTarget.style.display='none';const fallback=e.currentTarget.parentElement?.querySelector('.image-placeholder');if(fallback)fallback.classList.remove('image-fallback-hidden')}}/>:null}<div className={`image-placeholder ${img?'image-fallback-hidden':''}`}><Gift size={40}/><span>WORLD TREE</span></div><span className={`status ${c.status==='sold_out'?'sold':''}`}>{c.status==='sold_out'?'Agotado':'Combo'}</span><span className="combo-view-hint">Ver contenido <ArrowRight size={13}/></span></div></button><div className="product-body"><small className="product-category">Combo / promoción · {items.length} productos</small><button className="combo-title-button" onClick={()=>setSelectedCombo(c)}>{c.name}</button><p className="combo-description">{c.description||'Descubre todo lo que incluye este combo.'}</p><div className="combo-highlights">{highlights.map((item,index)=><span key={item.products?.id||index}>{item.products?.name||'Producto'}{item.quantity>1?` ×${item.quantity}`:''}</span>)}{items.length>highlights.length&&<span className="combo-more">+{items.length-highlights.length} más</span>}</div><div className="product-bottom"><strong>{price===undefined?'Precio pendiente':money(price,tariff)}</strong><button className={justAdded===`combo-${c.id}`?'added':''} disabled={c.status==='sold_out'||price===undefined} onClick={()=>addLine({id:c.id,name:c.name,kind:'combo',quantity:1,price,status:c.status})} aria-label={`Añadir ${c.name}`}><Plus size={18}/></button></div>{price===undefined&&<small className="missing-price">Tarifa aún no registrada</small>}</div></article>}

 return <div className="site-shell">
  <div className="topline">ENTREGAS EN SANTIAGO DE CUBA · PEDIDOS POR WHATSAPP</div>
  <header className="header"><a className="brand" href="#"><img className="brand-logo" src="/brand/world-tree-logo.jpg" alt="World Tree"/><span><strong>WORLD TREE</strong><small>TIENDA ONLINE</small></span></a><div className="header-right"><label className="tariff-select"><span>Tarifa</span><select value={tariff} onChange={e=>setTariff(e.target.value as Tariff)}>{tariffs.map(t=><option key={t} value={t}>{t==='Guyana'?'Guyana (DGY)':t==='Western'?'Western Union':t}</option>)}</select></label><button className="cart-button" onClick={()=>setShowCart(true)}><ShoppingBag size={18}/><span>Carrito</span><b>{cart.reduce((n,l)=>n+l.quantity,0)}</b></button></div></header>
  <main>
   <section className="hero"><div className="hero-copy"><span className="eyebrow">TU MUNDO, EN UN SOLO LUGAR</span><h1>Lo que necesitas,<br/><em>más cerca de casa.</em></h1><p>Alimentos, productos para el hogar y mucho más, para quienes quieren cuidar de los suyos en Santiago de Cuba.</p><a className="primary-link" href="#catalog">Explorar catálogo <ArrowRight size={17}/></a><div className="hero-trust"><span><ShieldCheck size={16}/> Atención personalizada</span><span><MapPin size={16}/> Santiago de Cuba</span></div></div><div className="hero-art"><div className="orbit orbit-one"></div><div className="planet">🌎</div><div className="tree-crown">🌳</div><div className="gold-seal">WORLD TREE<br/><small>TIENDA ONLINE</small></div></div></section>
   <section className="service-strip"><div><MapPin/><span><b>Entrega local</b><small>Santiago de Cuba y sus municipios</small></span></div><div><Clock3/><span><b>Pedidos por encargo</b><small>Tiempo estimado: 24 a 48 horas</small></span></div><div><ShieldCheck/><span><b>Atención directa</b><small>Confirmación por WhatsApp</small></span></div></section>
   <section id="catalog" className="catalog"><div className="section-heading"><div><span className="eyebrow">CATÁLOGO</span><h2>Encuentra tus favoritos</h2><p>La disponibilidad y el importe final se confirman al coordinar el pedido.</p></div><label className="search-box"><Search size={18}/><input value={query} onChange={e=>setQuery(e.target.value)} placeholder="Buscar productos…"/></label></div>
    <div className="category-row">{['Todos',...categories.map(c=>c.name)].map(c=><button key={c} onClick={()=>setCategory(c)} className={category===c?'category active':'category'}>{c}</button>)}</div>
    <div className="category-row"><button className={catalogMode==='products'?'category active':'category'} onClick={()=>setCatalogMode('products')}>Productos</button><button className={catalogMode==='combos'?'category active':'category'} onClick={()=>setCatalogMode('combos')}>Combos y promociones</button></div>
    {loading?<div className="empty"><RefreshCw size={18}/> Cargando catálogo…</div>:loadError?<div className="empty">{loadError}</div>:catalogMode==='products'?<div className="product-grid">{visibleProducts.map(p=><ProductCard key={p.id} p={p}/>)}</div>:<div className="product-grid">{visibleCombos.map(c=><ComboCard key={c.id} c={c}/>)}</div>}
    {!loading&&!loadError&&catalogMode==='products'&&!visibleProducts.length&&<div className="empty">{normalizedQuery?'No encontramos productos con ese término. Prueba otra palabra.':'Todavía no hay productos publicados en esta categoría.'}</div>}
    {!loading&&!loadError&&catalogMode==='combos'&&!visibleCombos.length&&<div className="empty">{normalizedQuery?'No encontramos combos o productos con ese término. Prueba otra palabra.':'Próximamente publicaremos combos y promociones.'}</div>}
   </section>
   <section className="delivery-note"><div className="delivery-mark"><MapPin size={25}/></div><div><h2>Entregamos en Santiago de Cuba</h2><p>Los municipios disponibles se muestran al realizar la solicitud. Los repartos a municipios se coordinan para los sábados. Otras provincias estarán disponibles cuando la propietaria las habilite.</p></div></section>
  </main>
  <footer><div className="footer-brand"><img className="footer-logo" src="/brand/world-tree-logo.jpg" alt=""/><strong>WORLD TREE</strong></div><span>Tu mundo, en un solo lugar.</span><small>Los pedidos se confirman personalmente por WhatsApp. Los precios y la disponibilidad pueden variar hasta la confirmación.</small></footer>
  {selectedCombo&&<div className="combo-modal-backdrop" onClick={()=>setSelectedCombo(null)}><section className="combo-modal" role="dialog" aria-modal="true" aria-labelledby="combo-modal-title" onClick={e=>e.stopPropagation()}><div className="combo-modal-head"><div><span className="eyebrow">WORLD TREE · CONTENIDO DEL COMBO</span><h2 id="combo-modal-title">{selectedCombo.name}</h2><p>{selectedCombo.description}</p></div><button className="icon-button" onClick={()=>setSelectedCombo(null)} aria-label="Cerrar detalle"><X/></button></div><div className="combo-modal-price"><span>Precio en {tariff}</span><strong>{comboPrice(selectedCombo)===undefined?'Precio pendiente':money(comboPrice(selectedCombo)!,tariff)}</strong></div><h3 className="combo-list-title">Todo lo que incluye ({selectedCombo.combo_items.length} productos)</h3><div className="combo-product-list">{[...selectedCombo.combo_items].sort((a,b)=>(a.sort_order||0)-(b.sort_order||0)).map((item,index)=>{const product=item.products;const productImage=product?.product_images?.slice().sort((a,b)=>a.sort_order-b.sort_order)[0],productPhotoPath=productImage?.storage_path||product?.image_main;return <div className="combo-product-row" key={product?.id||index}><div className="combo-product-thumb">{productPhotoPath?<img src={imageUrl(productPhotoPath)} alt={productImage?.alt_text||product?.name||'Producto'} onError={e=>{e.currentTarget.style.display='none';const fallback=e.currentTarget.parentElement?.querySelector('.image-placeholder');if(fallback)fallback.classList.remove('image-fallback-hidden')}}/>:null}<div className={`image-placeholder ${productPhotoPath?'image-fallback-hidden':''}`}><TreePine size={23}/><span>WORLD TREE</span></div></div><div className="combo-product-info"><strong>{product?.name||'Producto'}</strong>{product?.description&&<small>{product.description}</small>}</div><span className="combo-product-quantity">× {item.quantity}</span></div>})}</div><div className="combo-modal-actions"><button className="combo-modal-add" disabled={selectedCombo.status==='sold_out'||comboPrice(selectedCombo)===undefined} onClick={()=>{addLine({id:selectedCombo.id,name:selectedCombo.name,kind:'combo',quantity:1,price:comboPrice(selectedCombo),status:selectedCombo.status});setSelectedCombo(null)}}><Plus size={17}/> Añadir combo al carrito</button><button className="combo-modal-close" onClick={()=>setSelectedCombo(null)}>Seguir viendo combos</button></div></section></div>}
  {showCart&&<div className="overlay" onClick={()=>setShowCart(false)}><section className="drawer" role="dialog" aria-modal="true" aria-labelledby="cart-title" onClick={e=>e.stopPropagation()}><div className="drawer-head"><div><span className="eyebrow">TU PEDIDO</span><h2 id="cart-title">Carrito</h2></div><button className="icon-button" onClick={()=>setShowCart(false)} aria-label="Cerrar"><X/></button></div>
   {!cart.length?<div className="empty-cart"><ShoppingBag size={35}/><h3>Tu carrito está esperando</h3><p>Añade productos del catálogo para preparar la solicitud.</p></div>:<><div className="cart-lines">{cart.map(l=><div className="cart-line" key={`${l.kind}-${l.id}`}><div><b>{l.name}</b><small>{l.price===undefined?'Precio pendiente':money(l.price,tariff)} por unidad</small></div><div className="quantity"><button onClick={()=>changeQty(l.id,l.kind,-1)}><Minus size={14}/></button><span>{l.quantity}</span><button onClick={()=>changeQty(l.id,l.kind,1)}><Plus size={14}/></button></div><button className="remove" onClick={()=>setCart(prev=>prev.filter(x=>!(x.id===l.id&&x.kind===l.kind)))} aria-label="Eliminar"><X size={15}/></button></div>)}</div><div className="cart-total"><span>Subtotal estimado</span><strong>{money(subtotal,tariff)}</strong></div><p className="fineprint">Importe orientativo, sujeto a confirmación.</p>
   <div className="order-form"><h3>Datos para coordinar la entrega</h3><p>El nombre y carnet del destinatario deben coincidir al recibir la mercancía. Estos datos se incluirán en el mensaje de WhatsApp y no se guardarán en la web.</p>
    <label>Nombre completo del comprador *<input value={buyer.name} onChange={e=>setBuyer({...buyer,name:e.target.value})}/></label><label>Teléfono del comprador *<input value={buyer.phone} onChange={e=>setBuyer({...buyer,phone:e.target.value})}/></label><label>Nombre completo del destinatario *<input value={buyer.recipient} onChange={e=>setBuyer({...buyer,recipient:e.target.value})}/></label><label>Carnet de identidad del destinatario *<input value={buyer.idCard} onChange={e=>setBuyer({...buyer,idCard:e.target.value})} inputMode="numeric" autoComplete="off"/></label><label>Teléfono del destinatario *<input value={buyer.recipientPhone} onChange={e=>setBuyer({...buyer,recipientPhone:e.target.value})}/></label>
    <label>Municipio *<select value={buyer.municipality} onChange={e=>setBuyer({...buyer,municipality:e.target.value})}><option value="">Selecciona municipio</option>{(selectedMunicipalities.length?selectedMunicipalities:fallbackMunicipalities).map(m=><option key={m}>{m}</option>)}</select></label>
    <label>Dirección de entrega *<textarea value={buyer.address} onChange={e=>setBuyer({...buyer,address:e.target.value})}/></label><label>Indicaciones adicionales<textarea value={buyer.notes} onChange={e=>setBuyer({...buyer,notes:e.target.value})}/></label>
    <button className="send-order" onClick={sendOrder} disabled={!buyer.name.trim()||!buyer.phone.trim()||!buyer.recipient.trim()||!buyer.idCard.trim()||!buyer.recipientPhone.trim()||!buyer.municipality||!buyer.address.trim()||missingPrice}>Preparar pedido en WhatsApp <ArrowRight size={17}/></button><small className="privacy-note">No se envía nada hasta que pulses Enviar en WhatsApp. El carnet es un dato personal: compártelo únicamente si aceptas incluirlo en esta solicitud.</small>
   </div></>}
  </section></div>}
  {toast&&<div className="toast" style={{animationDuration:'2.5s'}}>{toast.msg}</div>}
 </div>
}
