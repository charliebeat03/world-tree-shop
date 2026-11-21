import { useCallback, useEffect, useState } from 'react'
import type { FormEvent } from 'react'
import { supabase, supabaseConfigured } from './lib_supabase'
import { ArrowLeft, LogOut, PackagePlus, RefreshCw, ShieldCheck, Pencil, Trash2, ImagePlus, MapPin, Tags, X, Plus } from 'lucide-react'

type ProductRow = { id:string; name:string; slug:string; description:string; status:string; category_id:string; product_images?:{storage_path:string;alt_text:string;sort_order:number}[] }
type CategoryRow = { id:string; name:string }
type PriceOption = { id:string; code:string; display_name:string; is_active:boolean }
type Province = { id:string; name:string; is_enabled:boolean }
type Municipality = { id:string; province_id:string; name:string; is_enabled:boolean }

const statuses = [
  ['available','Disponible'], ['check_availability','Consultar disponibilidad'],
  ['sold_out','Agotado'], ['hidden','Oculto']
]
const emptyPrice = (options:PriceOption[]) => Object.fromEntries(options.map(o=>[o.id,''])) as Record<string,string>
const slugify = (value:string) => value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().trim().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'')

async function normalizeImage(file:File):Promise<File> {
  const bitmap=await createImageBitmap(file)
  const scale=Math.min(1,1800/Math.max(bitmap.width,bitmap.height))
  const canvas=document.createElement('canvas')
  canvas.width=Math.max(1,Math.round(bitmap.width*scale)); canvas.height=Math.max(1,Math.round(bitmap.height*scale))
  const ctx=canvas.getContext('2d')
  if(!ctx) throw new Error('No se pudo preparar la imagen.')
  ctx.drawImage(bitmap,0,0,canvas.width,canvas.height); bitmap.close()
  const blob=await new Promise<Blob>((resolve,reject)=>canvas.toBlob(b=>b?resolve(b):reject(new Error('No se pudo comprimir la imagen.')),'image/webp',0.84))
  return new File([blob],`${file.name.replace(/\.[^.]+$/,'')}.webp`,{type:'image/webp'})
}

export default function AdminApp() {
  const [email,setEmail] = useState('')
  const [password,setPassword] = useState('')
  const [authorized,setAuthorized] = useState(false)
  const [busy,setBusy] = useState(false)
  const [error,setError] = useState('')
  const [notice,setNotice] = useState('')
  const [products,setProducts] = useState<ProductRow[]>([])
  const [categories,setCategories] = useState<CategoryRow[]>([])
  const [options,setOptions] = useState<PriceOption[]>([])
  const [provinces,setProvinces] = useState<Province[]>([])
  const [municipalities,setMunicipalities] = useState<Municipality[]>([])
  const [productFilter,setProductFilter] = useState(''); const [onlyMissingImages,setOnlyMissingImages] = useState(false)
  const [comboFilter,setComboFilter] = useState('')
  const [combos,setCombos] = useState<any[]>([])
  const [name,setName] = useState(''); const [slug,setSlug] = useState(''); const [categoryId,setCategoryId] = useState('')
  const [description,setDescription] = useState(''); const [status,setStatus] = useState('check_availability')
  const [prices,setPrices] = useState<Record<string,string>>({}); const [imageFile,setImageFile] = useState<File|null>(null); const [existingProductImage,setExistingProductImage] = useState<string|null>(null); const [removeProductImage,setRemoveProductImage] = useState(false); const [imageProgress,setImageProgress] = useState(''); const [editing,setEditing] = useState<string|null>(null)
  const [comboEditing,setComboEditing] = useState<string|null>(null); const [comboName,setComboName] = useState(''); const [comboSlug,setComboSlug] = useState('')
  const [comboDescription,setComboDescription] = useState(''); const [comboStatus,setComboStatus] = useState('available')
  const [comboPrices,setComboPrices] = useState<Record<string,string>>({}); const [comboItems,setComboItems] = useState<Record<string,string>>({})
  const [comboImage,setComboImage] = useState<File|null>(null); const [existingComboImage,setExistingComboImage] = useState<string|null>(null); const [removeComboImage,setRemoveComboImage] = useState(false); const [promoStart,setPromoStart] = useState(''); const [promoEnd,setPromoEnd] = useState('')
  const [newCategory,setNewCategory] = useState(''); const [editingCategory,setEditingCategory] = useState<string|null>(null); const [editingCategoryName,setEditingCategoryName] = useState('')
  const [newProvince,setNewProvince] = useState(''); const [newMunicipality,setNewMunicipality] = useState(''); const [selectedProvince,setSelectedProvince] = useState('')
  const [showZonesModal,setShowZonesModal] = useState(false)

  // Modal states
  const [showProductModal,setShowProductModal] = useState(false)

  const [showComboModal,setShowComboModal] = useState(false)

  const [showCategoryModal,setShowCategoryModal] = useState(false)

  const refresh = useCallback(async () => {
    if (!supabase) return
    setBusy(true); setError('')
    const [p,c,o,pr,mu,co] = await Promise.all([
      supabase.from('products').select('id,name,slug,description,status,category_id,product_images(storage_path,alt_text,sort_order)').order('created_at',{ascending:false}),
      supabase.from('categories').select('id,name').order('sort_order'),
      supabase.from('pricing_options').select('id,code,display_name,is_active').order('sort_order'),
      supabase.from('provinces').select('id,name,is_enabled').order('sort_order'),
      supabase.from('municipalities').select('id,province_id,name,is_enabled').order('sort_order'),
      supabase.from('combos').select('id,name,slug,description,status,starts_at,ends_at').order('created_at',{ascending:false})
    ])
    const firstError = p.error || c.error || o.error || pr.error || mu.error || co.error
    if (firstError) setError(firstError.message)
    else {
      setProducts(p.data || []); setCategories(c.data || []); setOptions(o.data || [])
      setProvinces(pr.data || []); setMunicipalities(mu.data || []); setCombos(co.data || [])
      if (!categoryId && c.data?.[0]) setCategoryId(c.data[0].id)
      if (!selectedProvince && pr.data?.[0]) setSelectedProvince(pr.data[0].id)
    }
    setBusy(false)
  }, [categoryId,selectedProvince])

  const checkAdmin = useCallback(async (userId:string) => {
    if (!supabase) return false
    const {data,error:checkError} = await supabase.from('admin_users').select('user_id').eq('user_id',userId).eq('is_active',true).maybeSingle()
    if (checkError || !data) {
      await supabase.auth.signOut()
      setAuthorized(false)
      setError('Esta cuenta no está autorizada para administrar World Tree.')
      return false
    }
    setAuthorized(true)
    await refresh()
    return true
  }, [refresh])

  useEffect(() => {
    if (!supabase) return
    let alive = true
    supabase.auth.getSession().then(async ({data}) => {
      if (alive && data.session) await checkAdmin(data.session.user.id)
    })
    const {data:listener} = supabase.auth.onAuthStateChange((_event,next) => {
      if (!next) { setAuthorized(false); setProducts([]) }
    })
    return () => { alive=false; listener.subscription.unsubscribe() }
  }, [checkAdmin])

  async function login(e:FormEvent) {
    e.preventDefault()
    if (!supabase) return
    setBusy(true); setError('')
    const {data,error:loginError} = await supabase.auth.signInWithPassword({email,password})
    if (loginError || !data.user) setError(loginError?.message || 'No se pudo iniciar sesión.')
    else await checkAdmin(data.user.id)
    setBusy(false)
  }

  function resetForm() {
    setEditing(null); setName(''); setSlug(''); setDescription('')
    setStatus('check_availability'); setPrices(emptyPrice(options)); setImageFile(null); setExistingProductImage(null); setRemoveProductImage(false); setImageProgress(''); setShowProductModal(false)
  }

  async function editProduct(product:ProductRow) {
    if (!supabase) return
    setBusy(true); setError(''); setNotice('')
    const {data,error:priceError} = await supabase.from('product_prices').select('pricing_option_id,amount').eq('product_id',product.id)
    if (priceError) setError(priceError.message)
    setEditing(product.id); setName(product.name); setSlug(product.slug)
    setCategoryId(product.category_id); setDescription(product.description || ''); setStatus(product.status)
    const next = emptyPrice(options)
    for (const row of data || []) next[row.pricing_option_id] = String(row.amount)
    setPrices(next); setImageFile(null); setExistingProductImage(product.product_images?.[0]?.storage_path||null); setRemoveProductImage(false); setBusy(false)
    setShowProductModal(true)
  }

  async function saveProduct(e:FormEvent) {
    e.preventDefault()
    if (!supabase || !name.trim() || !categoryId) return
    if (imageFile && imageFile.size > 5 * 1024 * 1024) { setError('La imagen no puede superar 5 MB.'); return }
    if (imageFile && !['image/jpeg','image/png','image/webp'].includes(imageFile.type)) { setError('Formato no válido. Usa JPG, PNG o WebP.'); return }
    setBusy(true); setError(''); setNotice('')
    const safeSlug = slugify(slug || name)
    if (!safeSlug) { setError('Escribe un nombre válido para el identificador URL.'); setBusy(false); return }
    const payload = { name:name.trim(), slug:safeSlug, description:description.trim(), category_id:categoryId, status }
    let productId = editing
    if (editing) {
      const {error:updateError} = await supabase.from('products').update(payload).eq('id',editing)
      if (updateError) { setError(updateError.message); setBusy(false); return }
    } else {
      const {data,error:insertError} = await supabase.from('products').insert(payload).select('id').single()
      if (insertError || !data) { setError(insertError?.message || 'No se pudo crear el producto.'); setBusy(false); return }
      productId = data.id
    }
    const priceRows = options.flatMap(option => {
      const raw = prices[option.id]?.trim()
      if (!raw) return []
      const amount = Number(raw.replace(',','.'))
      if (!Number.isFinite(amount) || amount < 0) return []
      return [{product_id:productId!,pricing_option_id:option.id,amount}]
    })
    const {error:deletePriceError} = await supabase.from('product_prices').delete().eq('product_id',productId!)
    if (deletePriceError) { setError(deletePriceError.message); setBusy(false); return }
    if (priceRows.length) {
      const {error:priceSaveError} = await supabase.from('product_prices').insert(priceRows)
      if (priceSaveError) { setError(priceSaveError.message); setBusy(false); return }
    }
    if ((imageFile || removeProductImage) && productId) {
      const {data:oldImages,error:oldImagesError} = await supabase.from('product_images').select('id,storage_path').eq('product_id',productId)
      if (oldImagesError) { setError(`No se pudieron consultar las imágenes actuales: ${oldImagesError.message}`); setBusy(false); return }
      if (imageFile) {
        try {
          setImageProgress('Preparando y optimizando la fotografía…')
          const normalized = await normalizeImage(imageFile)
          const path = `${productId}/${crypto.randomUUID()}.webp`
          setImageProgress('Subiendo fotografía a Supabase Storage…')
          const {error:uploadError} = await supabase.storage.from('world-tree-products').upload(path,normalized,{upsert:false,contentType:'image/webp',cacheControl:'3600'})
          if (uploadError) { setError(`No se pudo subir la fotografía: ${uploadError.message}`); setImageProgress(''); setBusy(false); return }
          setImageProgress('Guardando referencia en la base de datos…')
          const {data:inserted,error:imageRowError} = await supabase.from('product_images').insert({product_id:productId,storage_path:path,alt_text:name.trim(),sort_order:0}).select('id,storage_path').single()
          if (imageRowError || !inserted) {
            await supabase.storage.from('world-tree-products').remove([path])
            setError(`La foto llegó a Storage, pero no se guardó en la tabla product_images: ${imageRowError?.message || 'Supabase no devolvió confirmación.'}`)
            setImageProgress(''); setBusy(false); return
          }
          const {data:checkRows,error:checkError} = await supabase.from('product_images').select('id,storage_path').eq('id',inserted.id).eq('product_id',productId)
          if (checkError || !checkRows?.length || checkRows[0].storage_path!==path) {
            setError(`No se pudo verificar la referencia de la fotografía en la base de datos: ${checkError?.message || 'Registro no encontrado.'}`)
            setImageProgress(''); setBusy(false); await refresh(); return
          }
          const oldPaths=(oldImages||[]).map((r:any)=>r.storage_path).filter((p:string)=>p!==path)
          if(oldPaths.length) {
            setImageProgress('Foto verificada. Retirando imágenes anteriores…')
            const {error:deleteRowsError}=await supabase.from('product_images').delete().eq('product_id',productId).neq('storage_path',path)
            if(deleteRowsError) { setError(`La nueva foto sí está guardada, pero no se pudieron retirar referencias anteriores: ${deleteRowsError.message}`); setImageProgress(''); setBusy(false); await refresh(); return }
            const {error:deleteFilesError}=await supabase.storage.from('world-tree-products').remove(oldPaths)
            if(deleteFilesError) { setError(`La nueva foto está guardada, pero no se pudieron limpiar archivos anteriores: ${deleteFilesError.message}`); setImageProgress(''); setBusy(false); await refresh(); return }
          }
        } catch (imageError) {
          setError(`No se pudo procesar la fotografía: ${imageError instanceof Error ? imageError.message : String(imageError)}`)
          setImageProgress(''); setBusy(false); return
        }
      } else if (removeProductImage) {
        const paths=(oldImages||[]).map((r:any)=>r.storage_path)
        const {error:deleteRowsError}=await supabase.from('product_images').delete().eq('product_id',productId)
        if(deleteRowsError) { setError(`No se pudo quitar la referencia de imagen: ${deleteRowsError.message}`); setBusy(false); return }
        if(paths.length) {
          const {error:deleteFilesError}=await supabase.storage.from('world-tree-products').remove(paths)
          if(deleteFilesError) { setError(`Se quitó la referencia, pero falló la eliminación del archivo: ${deleteFilesError.message}`); setBusy(false); return }
        }
      }
    }
    setNotice(imageFile ? 'Producto y fotografía guardados y verificados correctamente.' : removeProductImage ? 'Producto actualizado y fotografía eliminada.' : (editing ? 'Producto actualizado correctamente.' : 'Producto creado correctamente.'))
    setImageProgress(''); resetForm(); await refresh(); setBusy(false)
  }

  async function deleteProduct(product:ProductRow) {
    if (!supabase || !window.confirm(`¿Eliminar "${product.name}" y sus precios e imágenes asociadas?`)) return
    setBusy(true); setError('')
    const {data:comboLinks,error:linkError} = await supabase.from('combo_items').select('combo_id,combos(name)').eq('product_id',product.id)
    if (linkError) { setError(linkError.message); setBusy(false); return }
    if (comboLinks?.length) {
      const names = comboLinks.map((row:any)=>row.combos?.name).filter(Boolean).join(', ')
      setError(`No se puede eliminar todavía: este producto forma parte de ${names || 'uno o más combos'}. Edita esos combos y retira el producto primero.`)
      setBusy(false); return
    }
    const {data:images} = await supabase.from('product_images').select('storage_path').eq('product_id',product.id)
    const {error:deleteError} = await supabase.from('products').delete().eq('id',product.id)
    if (!deleteError && images?.length) await supabase.storage.from('world-tree-products').remove(images.map(i=>i.storage_path))
    if (deleteError) setError(deleteError.message)
    else { setNotice('Producto eliminado.'); if (editing===product.id) resetForm() }
    await refresh(); setBusy(false)
  }

  async function addCategory(e:FormEvent) {
    e.preventDefault()
    if (!supabase || !newCategory.trim()) return
    setBusy(true); const slug = slugify(newCategory)
    const {error:insertError} = await supabase.from('categories').insert({name:newCategory.trim(),slug,sort_order:categories.length+1})
    if (insertError) setError(insertError.message)
    else { setNewCategory(''); setNotice('Categoría creada.'); await refresh() }
    setBusy(false)
  }

  async function saveCategoryEdit(category:CategoryRow) {
    if (!supabase || !editingCategoryName.trim()) return
    setBusy(true); setError('')
    const {error:updateError} = await supabase.from('categories').update({
      name: editingCategoryName.trim(), slug: slugify(editingCategoryName)
    }).eq('id', category.id)
    if (updateError) setError(updateError.message)
    else { setNotice('Categoría actualizada.'); setEditingCategory(null); setEditingCategoryName(''); await refresh() }
    setBusy(false)
  }

  async function deleteCategory(category:CategoryRow) {
    if (!supabase) return
    const linked = products.some(product => product.category_id === category.id)
    if (linked) { setError('No se puede eliminar: primero reasigna o elimina los productos de esta categoría.'); return }
    if (!window.confirm(`¿Eliminar la categoría «${category.name}»?`)) return
    setBusy(true); setError('')
    const {error:deleteError} = await supabase.from('categories').delete().eq('id',category.id)
    if (deleteError) setError(deleteError.message)
    else { setNotice('Categoría eliminada.'); await refresh() }
    setBusy(false)
  }

  function resetCombo() {
    setComboEditing(null); setComboName(''); setComboSlug(''); setComboDescription('')
    setComboStatus('available'); setComboPrices(emptyPrice(options)); setComboItems({})
    setComboImage(null); setExistingComboImage(null); setRemoveComboImage(false); setPromoStart(''); setPromoEnd(''); setShowComboModal(false)
  }

  async function editCombo(combo:any) {
    if (!supabase) return
    setBusy(true); setError('')
    const [priceResult,itemResult] = await Promise.all([
      supabase.from('combo_prices').select('pricing_option_id,amount').eq('combo_id',combo.id),
      supabase.from('combo_items').select('product_id,quantity').eq('combo_id',combo.id)
    ])
    if (priceResult.error || itemResult.error) setError(priceResult.error?.message || itemResult.error?.message || 'No se pudo cargar el combo.')
    const nextPrices = emptyPrice(options)
    for (const row of priceResult.data || []) nextPrices[row.pricing_option_id] = String(row.amount)
    const nextItems:Record<string,string> = {}
    for (const row of itemResult.data || []) nextItems[row.product_id] = String(row.quantity)
    setComboEditing(combo.id); setComboName(combo.name); setComboSlug(combo.slug)
    setComboDescription(combo.description || ''); setComboStatus(combo.status)
    setComboPrices(nextPrices); setComboItems(nextItems)
    setPromoStart(combo.starts_at ? combo.starts_at.slice(0,16) : '')
    setPromoEnd(combo.ends_at ? combo.ends_at.slice(0,16) : '')
    setComboImage(null); setRemoveComboImage(false); const {data:comboImageRows}=await supabase.from('combo_images').select('storage_path').eq('combo_id',combo.id).order('sort_order').limit(1); setExistingComboImage(comboImageRows?.[0]?.storage_path||null); setBusy(false)
    setShowComboModal(true)
  }

  async function saveCombo(e:FormEvent) {
    e.preventDefault()
    if (!supabase || !comboName.trim()) return
    if (comboImage && comboImage.size > 5 * 1024 * 1024) { setError('La imagen del combo no puede superar 5 MB.'); return }
    if (comboImage && !['image/jpeg','image/png','image/webp'].includes(comboImage.type)) { setError('Formato no válido. Usa JPG, PNG o WebP.'); return }
    const items = (Object.entries(comboItems) as [string,string][]).filter(([,q])=>q.trim() && Number(q)>0)
    if (!items.length) { setError('Añade al menos un producto al combo y define su cantidad.'); return }
    if (promoStart && promoEnd && new Date(promoEnd)<=new Date(promoStart)) { setError('La fecha final debe ser posterior a la inicial.'); return }
    setBusy(true); setError(''); setNotice('')
    const payload = {name:comboName.trim(),slug:slugify(comboSlug||comboName),description:comboDescription.trim(),status:comboStatus,
      starts_at:promoStart?new Date(promoStart).toISOString():null,ends_at:promoEnd?new Date(promoEnd).toISOString():null}
    let id = comboEditing
    if (id) {
      const {error:updateError}=await supabase.from('combos').update(payload).eq('id',id)
      if (updateError) {setError(updateError.message);setBusy(false);return}
    } else {
      const {data,error:insertError}=await supabase.from('combos').insert(payload).select('id').single()
      if (insertError||!data) {setError(insertError?.message||'No se pudo crear el combo.');setBusy(false);return}
      id=data.id
    }
    const {error:itemDeleteError}=await supabase.from('combo_items').delete().eq('combo_id',id)
    if (itemDeleteError) {setError(itemDeleteError.message);setBusy(false);return}
    const {error:itemInsertError}=await supabase.from('combo_items').insert(items.map(([product_id,q])=>({combo_id:id,product_id,quantity:Number(q)})))
    if (itemInsertError) {setError(itemInsertError.message);setBusy(false);return}
    const {error:priceDeleteError}=await supabase.from('combo_prices').delete().eq('combo_id',id)
    if (priceDeleteError) {setError(priceDeleteError.message);setBusy(false);return}
    const priceRows=options.flatMap(option=>{const raw=comboPrices[option.id]?.trim();if(!raw)return[];const amount=Number(raw.replace(',','.'));return Number.isFinite(amount)&&amount>=0?[{combo_id:id,pricing_option_id:option.id,amount}]:[]})
    if(priceRows.length){const {error:priceInsertError}=await supabase.from('combo_prices').insert(priceRows);if(priceInsertError){setError(priceInsertError.message);setBusy(false);return}}
    if(comboImage){
      const path=`combos/${id}/${crypto.randomUUID()}.webp`
      const optimizedComboImage=await normalizeImage(comboImage)
      const {error:uploadError}=await supabase.storage.from('world-tree-products').upload(path,optimizedComboImage,{contentType:'image/webp',cacheControl:'3600'})
      if(uploadError){setError(`Combo guardado, pero falló la imagen: ${uploadError.message}`);setBusy(false);await refresh();return}
      const {data:oldImages,error:oldImagesError}=await supabase.from('combo_images').select('storage_path').eq('combo_id',id)
      if(oldImagesError){
        await supabase.storage.from('world-tree-products').remove([path])
        setError(`La imagen se cargó, pero no se pudieron consultar las imágenes anteriores: ${oldImagesError.message}`)
        setBusy(false);return
      }
      const {data:insertedComboImage,error:imageError}=await supabase.from('combo_images').insert({combo_id:id,storage_path:path,alt_text:comboName.trim(),sort_order:0}).select('id,storage_path').single()
      if(imageError || !insertedComboImage){
        await supabase.storage.from('world-tree-products').remove([path])
        setError(`La imagen se cargó, pero no se pudo guardar su referencia en la base de datos: ${imageError?.message||'Supabase no devolvió confirmación.'}`)
        setBusy(false);return
      }
      const {data:verifiedComboRows,error:verifyComboError}=await supabase.from('combo_images').select('id,storage_path').eq('id',insertedComboImage.id).eq('combo_id',id)
      if(verifyComboError || !verifiedComboRows?.length || verifiedComboRows[0].storage_path!==path){
        setError(`La foto del combo se subió, pero no se pudo verificar en la base de datos: ${verifyComboError?.message||'Registro no encontrado.'}`)
        setBusy(false);await refresh();return
      }
      if(oldImages?.length){
        const {error:oldRowsError}=await supabase.from('combo_images').delete().eq('combo_id',id).neq('storage_path',path)
        if(oldRowsError){setError(`La nueva imagen quedó vinculada, pero no se pudieron retirar las referencias anteriores: ${oldRowsError.message}`);setBusy(false);await refresh();return}
        const {error:oldFilesError}=await supabase.storage.from('world-tree-products').remove(oldImages.map((i:any)=>i.storage_path))
        if(oldFilesError){setError(`La imagen nueva quedó guardada, pero no se pudieron borrar algunos archivos antiguos: ${oldFilesError.message}`);setBusy(false);await refresh();return}
      }
    } else if(removeComboImage && id) {
      const {data:oldComboImages,error:oldComboImagesError}=await supabase.from('combo_images').select('storage_path').eq('combo_id',id)
      if(oldComboImagesError){setError(`No se pudo consultar la imagen del combo: ${oldComboImagesError.message}`);setBusy(false);return}
      const {error:removeComboRowsError}=await supabase.from('combo_images').delete().eq('combo_id',id)
      if(removeComboRowsError){setError(`No se pudo quitar la referencia de imagen del combo: ${removeComboRowsError.message}`);setBusy(false);return}
      if(oldComboImages?.length){const {error:removeComboFilesError}=await supabase.storage.from('world-tree-products').remove(oldComboImages.map((r:any)=>r.storage_path));if(removeComboFilesError){setError(`Se quitó la referencia, pero no se pudieron borrar todos los archivos: ${removeComboFilesError.message}`);setBusy(false);return}}
    }
    setNotice(comboImage ? 'Combo y fotografía guardados y verificados correctamente.' : removeComboImage ? 'Combo actualizado y fotografía eliminada.' : (comboEditing?'Combo actualizado correctamente.':'Combo creado correctamente.'))
    resetCombo(); await refresh(); setBusy(false)
  }

  async function deleteCombo(combo:any) {
    if (!supabase || !window.confirm(`¿Eliminar «${combo.name}» y su configuración?`)) return
    setBusy(true); setError('')
    const {data:images}=await supabase.from('combo_images').select('storage_path').eq('combo_id',combo.id)
    if(images?.length) await supabase.storage.from('world-tree-products').remove(images.map((i:any)=>i.storage_path))
    const {error:deleteError}=await supabase.from('combos').delete().eq('id',combo.id)
    if(deleteError)setError(deleteError.message)
    else{setNotice('Combo eliminado.');if(comboEditing===combo.id)resetCombo()}
    await refresh();setBusy(false)
  }

  async function toggleProvince(p:Province) {
    if (!supabase) return
    setBusy(true); setError('')
    const {error:updateError} = await supabase.from('provinces').update({is_enabled:!p.is_enabled}).eq('id',p.id)
    if (updateError) setError(updateError.message)
    else { setNotice(`Provincia ${p.is_enabled?'deshabilitada':'habilitada'}.`); await refresh() }
    setBusy(false)
  }

  async function toggleMunicipality(m:Municipality) {
    if (!supabase) return
    setBusy(true); setError('')
    const {error:updateError} = await supabase.from('municipalities').update({is_enabled:!m.is_enabled}).eq('id',m.id)
    if (updateError) setError(updateError.message)
    else await refresh()
    setBusy(false)
  }

  async function addProvince(e:FormEvent) {
    e.preventDefault()
    if (!supabase || !newProvince.trim()) return
    setBusy(true)
    const {error:insertError} = await supabase.from('provinces').insert({name:newProvince.trim(),slug:slugify(newProvince),is_enabled:false,sort_order:provinces.length+1})
    if (insertError) setError(insertError.message)
    else { setNewProvince(''); setNotice('Provincia añadida, inicialmente deshabilitada.'); await refresh() }
    setBusy(false)
  }

  async function addMunicipality(e:FormEvent) {
    e.preventDefault()
    if (!supabase || !newMunicipality.trim() || !selectedProvince) return
    setBusy(true)
    const {error:insertError} = await supabase.from('municipalities').insert({province_id:selectedProvince,name:newMunicipality.trim(),slug:`${slugify(provinces.find(p=>p.id===selectedProvince)?.name||'zona')}-${slugify(newMunicipality)}`,is_enabled:false,sort_order:municipalities.filter(m=>m.province_id===selectedProvince).length+1})
    if (insertError) setError(insertError.message)
    else { setNewMunicipality(''); setNotice('Municipio añadido, inicialmente deshabilitado.'); await refresh() }
    setBusy(false)
  }

  async function renameProvince(province:Province) {
    if (!supabase) return
    const nextName=window.prompt('Nuevo nombre de la provincia:',province.name)?.trim()
    if(!nextName || nextName===province.name) return
    setBusy(true); setError('')
    const {error:updateError}=await supabase.from('provinces').update({name:nextName,slug:slugify(nextName)}).eq('id',province.id)
    if(updateError)setError(updateError.message)
    else {setNotice('Provincia actualizada.'); await refresh()}
    setBusy(false)
  }

  async function renameMunicipality(municipality:Municipality) {
    if (!supabase) return
    const nextName=window.prompt('Nuevo nombre del municipio:',municipality.name)?.trim()
    if(!nextName || nextName===municipality.name) return
    const provinceName=provinces.find(p=>p.id===municipality.province_id)?.name||'zona'
    setBusy(true); setError('')
    const {error:updateError}=await supabase.from('municipalities').update({name:nextName,slug:`${slugify(provinceName)}-${slugify(nextName)}`}).eq('id',municipality.id)
    if(updateError)setError(updateError.message)
    else {setNotice('Municipio actualizado.'); await refresh()}
    setBusy(false)
  }

  async function deleteProvince(province:Province) {
    if (!supabase || !window.confirm(`¿Eliminar ${province.name} y todos sus municipios? Esta acción no se puede deshacer.`)) return
    setBusy(true); setError('')
    const {error:deleteError}=await supabase.from('provinces').delete().eq('id',province.id)
    if(deleteError)setError(deleteError.message)
    else {setNotice(`Provincia ${province.name} eliminada junto con sus municipios.`); if(selectedProvince===province.id)setSelectedProvince(''); await refresh()}
    setBusy(false)
  }

  async function deleteMunicipality(municipality:Municipality) {
    if (!supabase || !window.confirm(`¿Eliminar el municipio ${municipality.name}?`)) return
    setBusy(true); setError('')
    const {error:deleteError}=await supabase.from('municipalities').delete().eq('id',municipality.id)
    if(deleteError)setError(deleteError.message)
    else {setNotice(`Municipio ${municipality.name} eliminado.`); await refresh()}
    setBusy(false)
  }

  async function logout() { if (supabase) await supabase.auth.signOut(); setAuthorized(false) }

  if (!supabaseConfigured) return <main className="admin-page"><a href="/" className="back-link"><ArrowLeft size={16}/> Volver a la tienda</a><section className="admin-card"><ShieldCheck size={34}/><h1>Configurar World Tree</h1><p>El panel necesita un proyecto Supabase. Copia <code>.env.example</code> a <code>.env.local</code> y añade la URL y la clave publishable.</p><p className="admin-warning">No introduzcas una clave service_role en el navegador. La cuenta propietaria debe crearse en Supabase Auth y añadirse a admin_users mediante un proceso de confianza.</p></section></main>

  if (!authorized) return <main className="admin-page"><a href="/" className="back-link"><ArrowLeft size={16}/> Volver a la tienda</a><form className="admin-card" onSubmit={login}><div className="admin-emblem"><ShieldCheck/></div><span className="eyebrow">WORLD TREE · ADMINISTRACIÓN</span><h1>Acceso privado</h1><p>Inicia sesión con la cuenta autorizada por la propietaria.</p><label>Correo electrónico<input type="email" autoComplete="username" value={email} onChange={e=>setEmail(e.target.value)} required/></label><label>Contraseña<input type="password" autoComplete="current-password" value={password} onChange={e=>setPassword(e.target.value)} required/></label>{error && <p className="admin-error">{error}</p>}<button className="send-order" disabled={busy}>{busy?'Comprobando…':'Iniciar sesión'}</button><small>No existe registro público de cuentas.</small></form></main>

  return <main className="admin-page admin-dashboard"><header className="admin-top"><div className="admin-brand-heading"><img src="/brand/world-tree-logo.jpg" alt="World Tree"/><div><span className="eyebrow">WORLD TREE</span><h1>Panel de administración</h1></div></div><p>Tu amiga podrá añadir tantos productos como necesite, sin límite impuesto por la aplicación.</p><button className="admin-logout" onClick={logout}><LogOut size={16}/> Cerrar sesión</button></header>
    {error && <p className="admin-error">{error}</p>}{notice && <p className="admin-notice">{notice}</p>}
    <nav className="admin-quick-nav" aria-label="Acceso rápido a secciones de administración">
      <span>Ir directamente a:</span>
      <a href="#combo-editor">Combos y promociones</a>
      <a href="#category-editor">Categorías</a>
      <a href="#delivery-zones">Zonas de entrega</a>
    </nav>
    <section className="admin-card" id="products"><div className="admin-section-title" style={{display:'flex',justifyContent:'space-between',alignItems:'center',marginBottom:10}}><div><h2><PackagePlus size={18}/> Productos</h2><p>{products.length} producto{products.length!==1?'s':''} registrados</p></div><button className="refresh" style={{background:'#07152e',color:'#fff'}} onClick={()=>{resetForm();setShowProductModal(true)}}><Plus size={14}/> Nuevo producto</button></div>
      <div className="admin-filters"><label>Buscar producto</label><input type="text" value={productFilter} onChange={e=>setProductFilter(e.target.value)} placeholder="Buscar por nombre o slug"/><label className="image-filter"><input type="checkbox" checked={onlyMissingImages} onChange={e=>setOnlyMissingImages(e.target.checked)}/> Solo productos sin fotografía</label><button className="refresh" onClick={refresh} disabled={busy}><RefreshCw size={14}/> Actualizar</button></div>
      {showProductModal && <div className="admin-modal-backdrop" onMouseDown={e=>{if(e.target===e.currentTarget)resetForm()}}><section className="admin-modal" role="dialog" aria-modal="true" aria-labelledby="product-modal-title"><div className="admin-modal-heading"><h3 id="product-modal-title">{editing?'Editar producto':'Nuevo producto'}</h3><button type="button" className="danger-button" onClick={resetForm}><X size={18}/></button></div><form className="admin-product-form" onSubmit={saveProduct}>
      <label>Nombre del producto<input value={name} onChange={e=>{setName(e.target.value);if(!editing)setSlug(slugify(e.target.value))}} required/></label>
        <label>Identificador URL<input value={slug} onChange={e=>setSlug(e.target.value)} placeholder="se-genera-del-nombre" required/></label>
        <label>Categoría<select value={categoryId} onChange={e=>setCategoryId(e.target.value)} required><option value="">Selecciona</option>{categories.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label>
        <label>Disponibilidad<select value={status} onChange={e=>setStatus(e.target.value)}>{statuses.map(([v,l])=><option key={v} value={v}>{l}</option>)}</select></label>
        <label className="wide">Descripción<textarea value={description} onChange={e=>setDescription(e.target.value)}/></label>
        <div className="wide price-editor"><h4>Precios por tarifa</h4><p>Deja vacío el precio que todavía no esté disponible. No se calcula ni convierte automáticamente.</p><div className="price-grid">{options.map(o=><label key={o.id}>{o.display_name}<input inputMode="decimal" placeholder="Precio pendiente" value={prices[o.id]||''} onChange={e=>setPrices({...prices,[o.id]:e.target.value})}/></label>)}</div></div>
        <label className="wide image-upload"><ImagePlus size={18}/> Fotografía del producto<input type="file" accept="image/jpeg,image/png,image/webp" onChange={e=>setImageFile(e.target.files?.[0]||null)}/><small>{imageFile?`Nueva fotografía seleccionada: ${imageFile.name}`:existingProductImage?'Fotografía guardada actualmente. Puedes reemplazarla o quitarla.':'Este producto no tiene fotografía guardada.'} · JPG, PNG o WebP · Máximo 5 MB.</small>{imageFile&&<img className="admin-image-preview" src={URL.createObjectURL(imageFile)} alt="Vista previa de la nueva fotografía"/>}{!imageFile&&existingProductImage&&supabase&&<img className="admin-image-preview" src={supabase.storage.from('world-tree-products').getPublicUrl(existingProductImage).data.publicUrl} alt="Fotografía actual del producto"/>}{editing&&existingProductImage&&<button type="button" className="danger-button" onClick={()=>{setExistingProductImage(null);setRemoveProductImage(true)}}>Quitar fotografía actual</button>}{imageProgress&&<small className="image-progress">{imageProgress}</small>}</label>
        <div className="wide form-actions"><button className="send-order" disabled={busy}>{busy?'Guardando…':editing?'Guardar cambios':'Crear producto'}</button>{editing&&<button type="button" className="refresh" onClick={resetForm}><X size={15}/> Cancelar edición</button>}</div>
      </form></section></div>}
      <div className="admin-product-list">{products.filter(p=>(p.name.toLowerCase().includes(productFilter.toLowerCase())||p.slug.includes(productFilter))&&(!onlyMissingImages||!p.product_images?.length)).map(product=><article key={product.id}><div><b>{product.name}</b><small>{product.slug} · {categories.find(c=>c.id===product.category_id)?.name||'Sin categoría'} · {statuses.find(s=>s[0]===product.status)?.[1]||product.status} · {product.product_images?.length?'Fotografía guardada':'SIN FOTOGRAFÍA'}</small></div><div className="row-actions"><button className="refresh" onClick={()=>editProduct(product)}><Pencil size={14}/> Editar</button><button className="danger-button" onClick={()=>deleteProduct(product)} aria-label={`Eliminar ${product.name}`}><Trash2 size={15}/></button></div></article>)}</div>
    </section>
    <section className="admin-card" id="combo-editor"><div className="admin-section-title"><div><h2>Combos y promociones</h2><p>{combos.filter(c=>c.name.toLowerCase().includes(comboFilter.toLowerCase())).length} de {combos.length} combos</p></div><button type="button" className="refresh" onClick={()=>{resetCombo();setShowComboModal(true)}}><Plus size={14}/> Nuevo combo</button></div>
      {showComboModal && <div className="admin-modal-backdrop" onMouseDown={e=>{if(e.target===e.currentTarget)resetCombo()}}><section className="admin-modal" role="dialog" aria-modal="true"><div className="admin-modal-heading"><h3>{comboEditing?'Editar combo':'Nuevo combo o promoción'}</h3><button type="button" className="danger-button" onClick={resetCombo}><X size={18}/></button></div><form className="admin-product-form" onSubmit={saveCombo}><h3>{comboEditing?'Modificar combo':'Crear combo o promoción'}</h3>
        <label>Nombre<input value={comboName} onChange={e=>{setComboName(e.target.value);if(!comboEditing)setComboSlug(slugify(e.target.value))}} required/></label>
        <label>Identificador URL<input value={comboSlug} onChange={e=>setComboSlug(e.target.value)} required/></label>
        <label>Estado<select value={comboStatus} onChange={e=>setComboStatus(e.target.value)}><option value="available">Disponible</option><option value="sold_out">Agotado</option><option value="hidden">Oculto</option></select></label>
        <label className="wide">Descripción<textarea value={comboDescription} onChange={e=>setComboDescription(e.target.value)}/></label>
        <div className="wide"><h4>Productos incluidos y cantidades</h4><div className="combo-item-editor">{products.filter(p=>p.status!=='hidden').map(p=><label key={p.id}>{p.name}<input type="number" min="0" step="0.01" placeholder="0 = no incluir" value={comboItems[p.id]||''} onChange={e=>setComboItems({...comboItems,[p.id]:e.target.value})}/></label>)}</div></div>
        <div className="wide price-editor"><h4>Precio promocional independiente por tarifa</h4><p>Estos precios son propios del combo, no se calculan sumando los productos.</p><div className="price-grid">{options.map(o=><label key={o.id}>{o.display_name}<input inputMode="decimal" placeholder="Precio pendiente" value={comboPrices[o.id]||''} onChange={e=>setComboPrices({...comboPrices,[o.id]:e.target.value})}/></label>)}</div></div>
        <label>Inicio de promoción (opcional)<input type="datetime-local" value={promoStart} onChange={e=>setPromoStart(e.target.value)}/></label><label>Fin de promoción (opcional)<input type="datetime-local" value={promoEnd} onChange={e=>setPromoEnd(e.target.value)}/></label>
        <label className="wide image-upload"><ImagePlus size={18}/> Imagen del combo<input type="file" accept="image/jpeg,image/png,image/webp" onChange={e=>setComboImage(e.target.files?.[0]||null)}/><small>{comboImage?`Nueva fotografía seleccionada: ${comboImage.name}`:existingComboImage?'Fotografía guardada actualmente.':'Sin fotografía guardada.'} · JPG, PNG o WebP · Máximo 5 MB.</small>{comboImage&&<img className="admin-image-preview" src={URL.createObjectURL(comboImage)} alt="Vista previa del combo"/>}{!comboImage&&existingComboImage&&supabase&&<img className="admin-image-preview" src={supabase.storage.from('world-tree-products').getPublicUrl(existingComboImage).data.publicUrl} alt="Fotografía actual del combo"/>}{comboEditing&&existingComboImage&&<button type="button" className="danger-button" onClick={()=>setRemoveComboImage(true)}>Quitar fotografía actual</button>}</label>
        <div className="wide form-actions"><button className="send-order" disabled={busy}>{busy?'Guardando…':comboEditing?'Guardar cambios':'Crear combo'}</button>{comboEditing&&<button type="button" className="refresh" onClick={resetCombo}>Cancelar edición</button>}</div>
      </form></section></div>}
      <div className="admin-filters"><label>Buscar combo<input type="text" value={comboFilter} onChange={e=>setComboFilter(e.target.value)} placeholder="Buscar por nombre o slug"/></label></div>
      <div className="admin-product-list">{combos.filter(c=>c.name.toLowerCase().includes(comboFilter.toLowerCase())||c.slug.includes(comboFilter)).map(c=><article key={c.id}><div><b>{c.name}</b><small>{c.slug} · {c.status}{c.starts_at?` · Desde ${new Date(c.starts_at).toLocaleString()}`:''}{c.ends_at?` · Hasta ${new Date(c.ends_at).toLocaleString()}`:''}</small></div><div className="row-actions"><button className="refresh" onClick={()=>editCombo(c)}><Pencil size={14}/> Editar</button><button className="danger-button" onClick={()=>deleteCombo(c)} aria-label={`Eliminar ${c.name}`}><Trash2 size={15}/></button></div></article>)}</div>
    </section>
    <section className="admin-card" id="category-editor"><div className="admin-section-title"><div><h2><Tags size={19}/> Categorías</h2><p>{categories.length} categorías registradas</p></div><button type="button" className="refresh" onClick={()=>setShowCategoryModal(true)}><Plus size={14}/> Gestionar categorías</button></div>{showCategoryModal && <div className="admin-modal-backdrop" onMouseDown={e=>{if(e.target===e.currentTarget)setShowCategoryModal(false)}}><section className="admin-modal" role="dialog" aria-modal="true"><div className="admin-modal-heading"><h3>Gestionar categorías</h3><button type="button" className="danger-button" onClick={()=>setShowCategoryModal(false)}><X size={18}/></button></div><p>Añade, edita o elimina categorías.</p><form className="inline-admin-form" onSubmit={addCategory}><input value={newCategory} onChange={e=>setNewCategory(e.target.value)} placeholder="Nueva categoría" required/><button className="refresh" disabled={busy}>Añadir</button></form><div className="admin-category-list">{categories.map(c=><div className="admin-category-row" key={c.id}>{editingCategory===c.id ? <><input value={editingCategoryName} onChange={e=>setEditingCategoryName(e.target.value)}/><button className="refresh" onClick={()=>saveCategoryEdit(c)} disabled={busy}>Guardar</button><button className="refresh" onClick={()=>setEditingCategory(null)}>Cancelar</button></> : <><b>{c.name}</b><div className="row-actions"><button className="refresh" onClick={()=>{setEditingCategory(c.id);setEditingCategoryName(c.name)}}><Pencil size={14}/> Editar</button><button className="danger-button" onClick={()=>deleteCategory(c)} aria-label={`Eliminar ${c.name}`}><Trash2 size={15}/></button></div></>}</div>)}</div></section></div>}</section>
    <section className="admin-card" id="delivery-zones"><div className="admin-section-title"><div><h2><MapPin size={19}/> Zonas de entrega</h2><p>Gestiona provincias y municipios.</p></div><button type="button" className="refresh" onClick={()=>setShowZonesModal(true)}><Plus size={14}/> Gestionar zonas</button></div>{showZonesModal && <div className="admin-modal-backdrop" onMouseDown={e=>{if(e.target===e.currentTarget)setShowZonesModal(false)}}><section className="admin-modal" role="dialog" aria-modal="true"><div className="admin-modal-heading"><h3>Zonas de entrega</h3><button type="button" className="danger-button" onClick={()=>setShowZonesModal(false)}><X size={18}/></button></div><p>Inicialmente Santiago de Cuba y sus municipios. Las provincias nuevas se crean deshabilitadas hasta que la propietaria decida ofrecer entregas allí.</p>
      <form className="inline-admin-form" onSubmit={addProvince}><input value={newProvince} onChange={e=>setNewProvince(e.target.value)} placeholder="Añadir provincia" required/><button className="refresh" disabled={busy}>Añadir provincia</button></form>
      <div className="zone-list">{provinces.map(p=><div className="zone-block" key={p.id}><div className="zone-heading"><b>{p.name}</b><div className="row-actions"><label className="toggle-label"><input type="checkbox" checked={p.is_enabled} onChange={()=>toggleProvince(p)}/> Habilitada</label><button type="button" className="refresh" onClick={()=>renameProvince(p)} aria-label={`Editar provincia ${p.name}`}><Pencil size={14}/></button><button type="button" className="danger-button" onClick={()=>deleteProvince(p)} aria-label={`Eliminar provincia ${p.name}`}><Trash2 size={14}/></button></div></div><div className="municipality-list">{municipalities.filter(m=>m.province_id===p.id).map(m=><div className="municipality-row" key={m.id}><label><input type="checkbox" checked={m.is_enabled} onChange={()=>toggleMunicipality(m)}/>{m.name}</label><button type="button" className="refresh" onClick={()=>renameMunicipality(m)} aria-label={`Editar municipio ${m.name}`}><Pencil size={13}/></button><button type="button" className="danger-button" onClick={()=>deleteMunicipality(m)} aria-label={`Eliminar municipio ${m.name}`}><Trash2 size={13}/></button></div>)}</div></div>)}</div>
      <form className="inline-admin-form" onSubmit={addMunicipality}><select value={selectedProvince} onChange={e=>setSelectedProvince(e.target.value)}><option value="">Provincia</option>{provinces.map(p=><option key={p.id} value={p.id}>{p.name}</option>)}</select><input value={newMunicipality} onChange={e=>setNewMunicipality(e.target.value)} placeholder="Nuevo municipio" required/><button className="refresh" disabled={busy}>Añadir municipio</button></form></section></div>}
    </section>
    <section className="admin-card"><h2>Buenas prácticas</h2><p>Los productos agotados pueden seguir visibles, pero no deben poder añadirse al carrito. Los ocultos no aparecen en el catálogo público. Los precios vacíos se muestran como pendientes y no se convierten automáticamente. Mantén la cuenta propietaria privada y no habilites el registro público.</p></section>
  </main>
}
