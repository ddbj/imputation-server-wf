このノートブックでは、インピュテーションサーバの出力データを用いて、PRS の計算手順を説明します。
# Step 1 hail など、必要なモジュールを読み込みます
下記のコードを実行してください。 ページ上側のメニューバーにある 実行 ボタンを押下することで、実行することができます。


```python
import hail as hl
hl.init()
from hail.plot import show
from pprint import pprint
hl.plot.output_notebook()
```

    /usr/local/lib/python3.8/dist-packages/scipy/__init__.py:146: UserWarning: A NumPy version >=1.16.5 and <1.23.0 is required for this version of SciPy (detected version 1.23.1
      warnings.warn(f"A NumPy version >={np_minversion} and <{np_maxversion}"
    WARNING: An illegal reflective access operation has occurred
    WARNING: Illegal reflective access by org.apache.spark.unsafe.Platform (file:/usr/local/lib/python3.8/dist-packages/pyspark/jars/spark-unsafe_2.12-3.1.3.jar) to constructor java.nio.DirectByteBuffer(long,int)
    WARNING: Please consider reporting this to the maintainers of org.apache.spark.unsafe.Platform
    WARNING: Use --illegal-access=warn to enable warnings of further illegal reflective access operations
    WARNING: All illegal access operations will be denied in a future release


    2022-09-13 16:56:27 WARN  NativeCodeLoader:60 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable


    Setting default log level to "WARN".
    To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
    Running on Apache Spark version 3.1.3
    SparkUI available at http://b45c895afb21:4040
    Welcome to
         __  __     <>__
        / /_/ /__  __/ /
       / __  / _ `/ / /
      /_/ /_/\_,_/_/_/   version 0.2.97-937922d7f46c
    LOGGING: writing to /notebooks/hail-20220913-1656-0.2.97-937922d7f46c.log




<div class="bk-root">
    <a href="https://bokeh.org" target="_blank" class="bk-logo bk-logo-small bk-logo-notebook"></a>
    <span id="1001">Loading BokehJS ...</span>
</div>




# Step 2 ゲノムデータを読み込みます
下記のコードでは、一般的なゲノムデータのファイル形式である `VCF` フォーマット（`outputs/chr1.beagle.vcf.gz`）から `hail` のファイル形式である `matrix table`フォーマット (`outputs/chr1.beagle.mt`) に変換します。

下記のコードを実行した後、1分程度の待ち時間が生じます。



```python
hl.import_vcf('outputs/chr1.beagle.vcf.gz', force_bgz=True).write('outputs/chr1.beagle.mt', overwrite=True)
```

    2022-09-13 17:02:01 Hail: INFO: Coerced sorted dataset=====>        (6 + 1) / 7]
    2022-09-13 17:07:25 Hail: INFO: wrote matrix table with 2428653 rows and 2318 columns in 7 partitions to outputs/chr1.beagle.mt


`mt` というオブジェクトにゲノムデータを読み込みます。 なお、`mt` は `matrix table` の略です。



```python
mt = hl.read_matrix_table('outputs/chr1.beagle.mt')
```

読み込んだゲノムデータに含まれる研究対象者の人数とバリアントの個数を表示します。


```python
mt.count()
```




    (2428653, 2318)



(2428653, 2318)

と表示されました。

これは、次のことを意味します。

- 研究対象者の人数が 2318 名
- バリアントの個数が 2428,653 個


# Step 3 ゲノムデータに variantID を追加します
下記のコードは、読み込まれたゲノムデータのバリアント情報を表示します。

show(5) は、先頭の 5 個のバリアントのみを表示する、という意味です。


```python
mt.rows().show(5)
```


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">info</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">locus</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">alleles</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">rsid</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">qual</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">filters</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">AF</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">DR2</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">IMP</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">locus&lt;GRCh37&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">set&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">bool</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10177</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;A&quot;,&quot;AC&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs367896724&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.46e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10235</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;TA&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs540431307&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.00e-04]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10352</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;TA&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs555500075&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.73e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10616</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;CCGCCGTTGCAAAGGCGCGCCG&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs376342519&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.93e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10642</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;G&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs558604819&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.70e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 5 rows</p>



mt には multi-allelic site が含まれます。次にその割合を確認してみます。


```python
mt1 = mt.filter_rows(hl.len(mt.info.DR2) == 1)
mt1.count()
```




    (2399023, 2318)




```python
mtnot1 = mt.filter_rows(hl.len(mt.info.DR2) > 1)
mtnot1.count()
```




    (29630, 2318)



1% ほどが multi-allelic site であることがわかります。
1% は無視するにはやや多いですが、このチュートリアルでは内容をわかりやすくするために除外して進めます。

下記のコードは、ゲノムデータのバリアント情報に `variantID` を追加します。


```python
mt1 = mt1.annotate_rows(variantID = (hl.str(mt1.locus.contig) + ":" + hl.str(mt1.locus.position)) )
```


```python
mt1.rows().show(5)
```


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">info</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">locus</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">alleles</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">rsid</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">qual</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">filters</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">AF</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">DR2</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">IMP</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">variantID</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">locus&lt;GRCh37&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">set&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">bool</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10177</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;A&quot;,&quot;AC&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs367896724&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.46e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10177&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10235</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;TA&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs540431307&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.00e-04]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10235&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10352</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;TA&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs555500075&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.73e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10352&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10616</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;CCGCCGTTGCAAAGGCGCGCCG&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs376342519&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.93e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10616&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10642</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;G&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs558604819&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.70e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[0.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10642&quot;</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 5 rows</p>



`variantID` のカラムが追加されていることが分かります。

# Step 4 imputation quality に基づいてゲノムデータをフィルタリングします
下記のコードでは、各バリアントの `imputation quality` の分布を表示します。 1分程度の待ち時間が生じます。


```python
p = hl.plot.histogram(mt1.info.DR2.first(), title='Imputation Quality Histogram', legend='Imputation Quality (DR2)')
show(p)
```








<div class="bk-root" id="1a4c67ba-474c-403d-80d4-7532853c72f3" data-root-id="1002"></div>





`imputation quality` が低い（DR2 < 0.3）バリアントもいくつかあることが分かります。

下記のコードは、`imputation quality` が低い（DR2 < 0.3）バリアントを除外します。


```python
mt1_filt = mt1.filter_rows(mt1.info.DR2.first()>=0.3)
```

下記のコードは、`imputation quality` が低い（DR2 < 0.3）バリアントを除外した後の分布を表示します。


```python
p = hl.plot.histogram(mt1_filt.info.DR2.first(), title='Imputation Quality Histogram', legend='Imputation Quality (DR2)')
show(p)
```








<div class="bk-root" id="f053b8c1-a6e3-4de7-8408-41fd6a746c27" data-root-id="1105"></div>





`imputation quality` が低い（DR2 < 0.3）バリアントが除外されたことが分かります。

下記のコードは、`imputation quality` が低い（DR2 < 0.3）バリアントを除外したのちのバリアントの個数を表示します。


```python
mt1_filt.count()
```




    (2340844, 2318)



(2340844, 2318)
と表示されました。

これは、次のことを意味します。

- 研究対象者の人数が 2318 名
- バリアントの個数が 2340,844 個

下記のコードは、`imputation quality` が低い（DR2 < 0.3）バリアントを除外した後の allele frequency の分布を表示します。


```python
p = hl.plot.histogram(mt1_filt.info.AF.first(), title='AF Histogram', legend='AF', bins=50)
show(p)
```








<div class="bk-root" id="d2ac6d67-0ad8-4a5d-b91b-a14abc75b87c" data-root-id="1335"></div>





AF<1% のバリアントが多くあることが分かります。

# Step 5 PRSモデルを読み込みます
ここでは、PRSモデル `PGS000004` のみを読み込みます。

https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/PGS000004/ScoringFiles/PGS000004.txt.gz をダウンロード、解凍後得られる `PGS000004.txt` を何らかのエディタで開き、先頭の#で始まるコメント行をすべて削除し、`prs-models` フォルダを作成し、その中に保存します。

その後 下記のコードを実行すると、`prs-models/PGS000004.txt` のデータが読み込まれます。


```python
model_PGS000004 = hl.import_table('prs-models/PGS000004.txt', impute=True, force=True)
```

    2022-09-13 20:09:40 Hail: INFO: Reading table to impute column types
    2022-09-13 20:09:40 Hail: INFO: Finished type imputation
      Loading field 'chr_name' as type int32 (imputed)
      Loading field 'chr_position' as type int32 (imputed)
      Loading field 'effect_allele' as type str (imputed)
      Loading field 'other_allele' as type str (imputed)
      Loading field 'effect_weight' as type float64 (imputed)
      Loading field 'allelefrequency_effect' as type float64 (imputed)


下記のコードは、PRSモデルに含まれるバリアントの個数を表示します。


```python
model_PGS000004.count()
```




    313



`313` と表示されました。

これは、PRSモデルに含まれるバリアントの個数が 313 個であることを意味します。

# Step 6 PRSモデルに `variantID` を追加します
下記のコードは、読み込んだ PRS モデルの最初の 5 行（5 個のバリアントの情報）を表示します。


```python
model_PGS000004.show(5)
```


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_name</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_position</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">other_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_weight</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">allelefrequency_effect</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">100880328</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.73e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.10e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">10566215</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-5.86e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.29e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">110198129</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;CAAA&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.58e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">7.76e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">114445880</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">6.21e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.66e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">118141492</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.52e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">2.66e-01</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 5 rows</p>



下記のコードは、読み込んだ PRS モデルに `variantID` を追加します。


```python
model_PGS000004 = model_PGS000004.annotate(
    variantID = hl.str(model_PGS000004.chr_name) + ":" + hl.str(model_PGS000004.chr_position) 
) 
```

`variantID` を追加したのちの最初の 5 行を表示します。


```python
model_PGS000004.show(5)
```


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_name</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_position</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">other_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_weight</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">allelefrequency_effect</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">variantID</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">100880328</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.73e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.10e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:100880328&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">10566215</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-5.86e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.29e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10566215&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">110198129</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;CAAA&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.58e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">7.76e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:110198129&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">114445880</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">6.21e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.66e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:114445880&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">118141492</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.52e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">2.66e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:118141492&quot;</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 5 rows</p>



`variantID` のカラムが追加されていることが分かります。

# Step 7 ゲノムデータとPRSモデルに共通するバリアントを抽出します
下記のコードは、PRSモデルのバリアント情報を `variantID` で検索できるようにします。


```python
model_PGS000004 = model_PGS000004.key_by('variantID')
```

下記のコードは、ゲノムデータと PRS モデルに共通するバリアントを抽出します。


```python
mt1_filt.rows().show()
```


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">info</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">locus</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">alleles</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">rsid</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">qual</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">filters</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">AF</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">DR2</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">IMP</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">variantID</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">locus&lt;GRCh37&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">set&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">bool</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:534247</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs201475892&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[7.80e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:534247&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:565286</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs1578391&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.93e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:565286&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:674211</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs546906063&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[2.23e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.40e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:674211&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:701299</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;A&quot;,&quot;G&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs553919012&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[2.54e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[7.20e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:701299&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:701625</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs576411494&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[2.40e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[5.70e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:701625&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:702958</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs535793062&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.12e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[7.70e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:702958&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:703942</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;G&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs548160064&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[5.77e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.50e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:703942&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:705452</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs113340103&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[5.81e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.60e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:705452&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:705881</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs116763968&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.86e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.20e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:705881&quot;</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:706357</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;G&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs557777932&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.10e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.30e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:706357&quot;</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 10 rows</p>




```python
mt_match = mt1_filt.annotate_rows(**model_PGS000004[mt1_filt.variantID])
```


```python
mt_match = mt_match.filter_rows(hl.is_defined(mt_match.effect_weight))
```

下記のコードは、ゲノムデータと PRS モデルに共通するバリアントを表示します。 1分程度の待ち時間が生じます。


```python
mt_match.rows().show()
```

    2022-09-13 20:23:50 Hail: INFO: Ordering unsorted dataset with network shuffle7]
    2022-09-13 20:23:51 Hail: INFO: Ordering unsorted dataset with network shuffle
    2022-09-13 20:24:05 Hail: INFO: Ordering unsorted dataset with network shuffle7]
    [Stage 52:===========================================>              (3 + 1) / 4]


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">info</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">locus</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">alleles</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">rsid</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">qual</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">filters</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">AF</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">DR2</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">IMP</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">variantID</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_name</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_position</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">other_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_weight</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">allelefrequency_effect</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">locus&lt;GRCh37&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">set&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">bool</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:7917076</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;G&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs707475&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.36e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:7917076&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">7917076</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-4.09e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.90e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10566215</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;A&quot;,&quot;G&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs616488&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.00e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10566215&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">10566215</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-5.86e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.29e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:18807339</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs2992756&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[5.89e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:18807339&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">18807339</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-5.64e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">5.15e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:41380440</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs4233486&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[6.72e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:41380440&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">41380440</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.26e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">6.44e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:41389220</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs114282204&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.10e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.80e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:41389220&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">41389220</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.55e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.69e-02</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:46670206</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;TC&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs144105764&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.34e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.90e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:46670206&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">46670206</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;TC&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.47e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">2.97e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:51467096</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;CT&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs56168262&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.25e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.70e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:51467096&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">51467096</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;CT&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.74e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.80e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:88156923</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;G&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs17426269&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[7.98e-02]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:88156923&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">88156923</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.94e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.49e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:88428199</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs2151842&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.79e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:88428199&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">88428199</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-3.87e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">2.48e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:100880328</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;A&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs612683&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[4.00e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.90e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:100880328&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">100880328</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.73e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.10e-01</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 10 rows</p>



ゲノムデータと PRS モデルに共通するバリアントを抽出するために、`variantID` を利用しています。
`variantID` は、`染色体番号` と `塩基ポジション` から構成されます。

PRSを計算する際には、`染色体番号` と `塩基ポジション` だけでなく、`effect_allele` と `other_allele` もマッチさせる必要があります。 （そのための手順は後ほど解説します）

下記のコードは、ゲノムデータとPRSモデルに共通するバリアントを抽出した結果、ユニークな `variantID` が何個あるかをカウントします。 1分程度の待ち時間が生じます。


```python
len(dict(mt_match.aggregate_rows(hl.agg.counter(mt_match.variantID))))
```

    2022-09-13 20:31:32 Hail: INFO: Ordering unsorted dataset with network shuffle7]
    2022-09-13 20:31:32 Hail: INFO: Ordering unsorted dataset with network shuffle
    2022-09-13 20:31:46 Hail: INFO: Ordering unsorted dataset with network shuffle7]
    [Stage 61:=================================================>        (6 + 1) / 7]




    30



下記のコードは、PRSモデルのうち、1番染色体に位置するバリアントの個数を表示します。


```python
model_PGS000004.filter(model_PGS000004.chr_name==1).count()
```




    30



本チュートリアルでは、1番染色体のゲノムデータのみを用いています。
上記の結果から、PRSモデルの1番染色体バリアント 30 個のうち、30 個がゲノムデータに含まれていたことが分かります。

# Step 8 抽出したゲノムデータを保存します
今後のステップの実行時間を短縮するため、抽出したゲノムデータを保存し、再度読み込みます。

下記のコードは、抽出したゲノムデータを `outputs/chr1.beagle.matched.mt` に保存します。


```python
mt_match.write('outputs/chr1.beagle.matched.mt', overwrite=True)
```

    2022-09-13 20:42:55 Hail: INFO: Ordering unsorted dataset with network shuffle7]
    2022-09-13 20:42:56 Hail: INFO: Ordering unsorted dataset with network shuffle
    2022-09-13 20:43:10 Hail: INFO: Ordering unsorted dataset with network shuffle7]
    2022-09-13 20:43:46 Hail: INFO: wrote matrix table with 30 rows and 2318 columns in 7 partitions to outputs/chr1.beagle.matched.mt


下記のコードは、`outputs/chr1.beagle.matched.mt` を読み込みます。


```python
mt_match = hl.read_matrix_table('outputs/chr1.beagle.matched.mt')
```

# Step 9 ゲノムデータとPRSモデルのアリル情報を照合します
下記のコードは、ゲノムデータのアリル情報とPRSモデルのアリル情報を比較し、合致しているかをチェックします。

ゲノムデータのアリル情報は、`mt_match.alleles[0]` と `mt_match.alleles[1]` に保存されています。 PRSモデルのアリル情報は、`mt_match.effect_allele` と `mt_match.other_allele` に保存されています。

`mt_match.alleles[0]` と `mt_match.effect_allele` が一致しており、かつ、`mt_match.alleles[1]` と `mt_match.other_allele` が一致している場合は、後ほど `allele flip` の操作が必要であるため、`flip` フラグを立てます。

`mt_match.alleles[1]` と `mt_match.effect_allele` が一致しており、かつ、`mt_match.alleles[0]` と `mt_match.other_allele` が一致している場合は、後ほど `allele flip` の操作が必要ないため、`flip` フラグを立てません。


```python
flip = hl.case().when(
    (mt_match.effect_allele == mt_match.alleles[0])
    & (mt_match.other_allele == mt_match.alleles[1]), True ).when(
    (mt_match.effect_allele == mt_match.alleles[1])
    & (mt_match.other_allele == mt_match.alleles[0]), False ).or_missing()
```


```python
mt_match = mt_match.annotate_rows( flip=flip )
```

下記のコードは、`flip` フラグ情報を表示します。


```python
mt_match.rows().show(5)
```


<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="3"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">info</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">locus</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">alleles</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">rsid</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">qual</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">filters</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">AF</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">DR2</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">IMP</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">variantID</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_name</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">chr_position</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">other_allele</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">effect_weight</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">allelefrequency_effect</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">flip</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">locus&lt;GRCh37&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">set&lt;str&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">array&lt;float64&gt;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">bool</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">int32</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">bool</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:7917076</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;G&quot;,&quot;A&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs707475&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.36e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:7917076&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">7917076</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-4.09e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.90e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:10566215</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;A&quot;,&quot;G&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs616488&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[3.00e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:10566215&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">10566215</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;G&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;A&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-5.86e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.29e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:18807339</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs2992756&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[5.89e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:18807339&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">18807339</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-5.64e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">5.15e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:41380440</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;C&quot;,&quot;T&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs4233486&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[6.72e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[1.00e+00]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:41380440&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">41380440</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.26e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">6.44e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1:41389220</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[&quot;T&quot;,&quot;C&quot;]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;rs114282204&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-1.00e+01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">{}</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.10e-03]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">[9.80e-01]</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">True</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;1:41389220&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">41389220</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;C&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;T&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.55e-01</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.69e-02</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">False</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 5 rows</p>



- `flip` フラグが `False` の場合、`allele flip` の操作は必要ありません。
- `flip` フラグが `True` の場合、`allele flip` の操作が必要です。
- `flip` フラグが `NA` の場合、PRSモデルの `effect_allele` または `other_allele` がゲノムデータのアリル（`alleles[0]`および`alleles[1]`）と合致していないため、PRS計算時には考慮しません。

# Step 10 PRSを計算します
下記のコードは、各々のバリアントについて研究対象者の持っているアリル数（`mt_match.DS`）とバリアントの重み（`mt_match.effect_weight`）を掛け合わせて、ゲノムデータとPRSモデルの共通するバリアントについて足し合わせます。 これにより、PRSを計算することができます。

ここで、研究対象者の持っているアリル数を、下記のように計算しています。

- `flip` フラグが `False` の場合、`allele flip` の操作は必要ないため、`mt_match.DS` の値をアリル数として用います。
- `flip` フラグが `True` の場合、`allele flip` の操作が必要なため、`2 - mt_match.DS` の値をアリル数として用います。


```python
prs=hl.agg.sum(hl.float64(mt_match.effect_weight) * hl.if_else(mt_match.flip, 2 - mt_match.DS.first(), mt_match.DS.first()))
```


```python
mt_match = mt_match.annotate_cols(prs=prs)
```

下記のコードは、PRSの値を表示します。


```python
mt_match.cols().show(5)
```

    2022-09-13 21:11:34 Hail: WARN: cols(): Resulting column table is sorted by 'col_key'.
        To preserve matrix table column order, first unkey columns with 'key_cols_by()'



<table><thead><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;"></div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">s</div></td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; " colspan="1"><div style="text-align: left;border-bottom: solid 2px #000; padding-bottom: 5px">prs</div></td></tr><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">str</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; text-align: left;">float64</td></tr>
</thead><tbody><tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;_HG00096&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.23e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;_HG00097&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">3.13e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;_HG00098&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">-7.49e-02</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;_HG00099&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">1.61e-01</td></tr>
<tr><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">&quot;_HG00100&quot;</td><td style="white-space: nowrap; max-width: 500px; overflow: hidden; text-overflow: ellipsis; ">4.59e-01</td></tr>
</tbody></table><p style="background: #fdd; padding: 0.4em;">showing top 5 rows</p>



下記のコードは、PRSの分布を表示します。


```python
p = hl.plot.histogram(mt_match.prs, title="PRS Histogram", legend="PGS000004", bins=20)
show(p)
```








<div class="bk-root" id="b3665428-1ee6-4b29-86dd-d15ff6f681d2" data-root-id="1462"></div>





# Step 11 PRSの計算結果を保存します

chr1.beagle.matched.mt')

下記のコードは、PRSの計算結果を `chr1.beagle.PGS000004.PRS.txt` ファイルに保存します。


```python
mt_match.cols().export('chr1.beagle.PGS000004.PRS.txt')
```

    2022-09-13 21:13:50 Hail: INFO: Coerced sorted dataset
    2022-09-13 21:13:50 Hail: INFO: merging 17 files totalling 45.6K...
    2022-09-13 21:13:50 Hail: INFO: while writing:
        chr1.beagle.PGS000004.PRS.txt
      merge time: 8.741ms


以上でこのチュートリアルは終了です。


```python

```
